import 'package:flutter/foundation.dart';
import 'package:spinwishapp/services/api_service.dart';
import 'package:spinwishapp/widgets/error_state_widget.dart';

enum ApiState { idle, loading, success, error }

class ApiStateManager<T> extends ChangeNotifier {
  ApiState _state = ApiState.idle;
  T? _data;
  String? _error;
  ErrorType _errorType = ErrorType.unknown;
  bool _hasData = false;

  // Getters
  ApiState get state => _state;
  T? get data => _data;
  String? get error => _error;
  ErrorType get errorType => _errorType;
  bool get isLoading => _state == ApiState.loading;
  bool get hasError => _state == ApiState.error;
  bool get hasData => _hasData && _data != null;
  bool get isIdle => _state == ApiState.idle;
  bool get isSuccess => _state == ApiState.success;

  // Execute API call with comprehensive state management
  Future<T?> execute(Future<T> Function() apiCall, {
    bool clearPreviousData = false,
    bool showLoadingState = true,
  }) async {
    if (clearPreviousData) {
      _data = null;
      _hasData = false;
    }

    if (showLoadingState) {
      _setState(ApiState.loading);
    }

    try {
      final result = await apiCall();
      _data = result;
      _hasData = true;
      _error = null;
      _setState(ApiState.success);
      return result;
    } catch (e) {
      _handleError(e);
      return null;
    }
  }

  // Execute API call without changing loading state (for background updates)
  Future<T?> executeInBackground(Future<T> Function() apiCall) async {
    return execute(apiCall, showLoadingState: false);
  }

  // Refresh data (clear previous and reload)
  Future<T?> refresh(Future<T> Function() apiCall) async {
    return execute(apiCall, clearPreviousData: true);
  }

  // Reset state to idle
  void reset() {
    _state = ApiState.idle;
    _data = null;
    _error = null;
    _errorType = ErrorType.unknown;
    _hasData = false;
    notifyListeners();
  }

  // Clear error state
  void clearError() {
    if (_state == ApiState.error) {
      _state = _hasData ? ApiState.success : ApiState.idle;
      _error = null;
      notifyListeners();
    }
  }

  // Set data manually (useful for optimistic updates)
  void setData(T data) {
    _data = data;
    _hasData = true;
    _setState(ApiState.success);
  }

  // Update data without changing state
  void updateData(T data) {
    _data = data;
    _hasData = true;
    notifyListeners();
  }

  void _setState(ApiState newState) {
    _state = newState;
    notifyListeners();
  }

  void _handleError(dynamic error) {
    _error = error.toString();
    _errorType = _determineErrorType(error);
    _setState(ApiState.error);
  }

  ErrorType _determineErrorType(dynamic error) {
    if (error is ApiException) {
      final message = error.message.toLowerCase();
      
      if (message.contains('network') || message.contains('connection') || message.contains('internet')) {
        return ErrorType.network;
      } else if (message.contains('timeout')) {
        return ErrorType.timeout;
      } else if (message.contains('unauthorized') || message.contains('401')) {
        return ErrorType.authentication;
      } else if (message.contains('forbidden') || message.contains('403')) {
        return ErrorType.permission;
      } else if (message.contains('not found') || message.contains('404')) {
        return ErrorType.notFound;
      } else if (message.contains('validation') || message.contains('400')) {
        return ErrorType.validation;
      } else if (message.contains('server') || message.contains('500') || message.contains('502') || message.contains('503')) {
        return ErrorType.server;
      }
    }
    
    return ErrorType.unknown;
  }
}

// Specialized state managers for different data types
class ListApiStateManager<T> extends ApiStateManager<List<T>> {
  // Add item to list optimistically
  void addItem(T item) {
    if (_data != null) {
      _data!.add(item);
      notifyListeners();
    }
  }

  // Remove item from list optimistically
  void removeItem(bool Function(T) predicate) {
    if (_data != null) {
      _data!.removeWhere(predicate);
      notifyListeners();
    }
  }

  // Update item in list
  void updateItem(bool Function(T) predicate, T newItem) {
    if (_data != null) {
      final index = _data!.indexWhere(predicate);
      if (index != -1) {
        _data![index] = newItem;
        notifyListeners();
      }
    }
  }

  // Get item count
  int get itemCount => _data?.length ?? 0;

  // Check if list is empty
  bool get isEmpty => _data?.isEmpty ?? true;
}

class PaginatedApiStateManager<T> extends ListApiStateManager<T> {
  bool _hasMoreData = true;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  final int _pageSize;

  PaginatedApiStateManager({int pageSize = 20}) : _pageSize = pageSize;

  bool get hasMoreData => _hasMoreData;
  bool get isLoadingMore => _isLoadingMore;
  int get currentPage => _currentPage;
  int get pageSize => _pageSize;

  // Load first page
  Future<List<T>?> loadFirstPage(Future<List<T>> Function(int page, int pageSize) apiCall) async {
    _currentPage = 1;
    _hasMoreData = true;
    return execute(() => apiCall(_currentPage, _pageSize), clearPreviousData: true);
  }

  // Load next page
  Future<List<T>?> loadNextPage(Future<List<T>> Function(int page, int pageSize) apiCall) async {
    if (!_hasMoreData || _isLoadingMore) return null;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final nextPage = _currentPage + 1;
      final newItems = await apiCall(nextPage, _pageSize);
      
      if (newItems.isEmpty || newItems.length < _pageSize) {
        _hasMoreData = false;
      }

      if (newItems.isNotEmpty) {
        _data ??= [];
        _data!.addAll(newItems);
        _currentPage = nextPage;
        _hasData = true;
        _setState(ApiState.success);
      }

      return newItems;
    } catch (e) {
      _handleError(e);
      return null;
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  // Refresh pagination
  Future<List<T>?> refresh(Future<List<T>> Function(int page, int pageSize) apiCall) async {
    return loadFirstPage(apiCall);
  }

  @override
  void reset() {
    super.reset();
    _hasMoreData = true;
    _isLoadingMore = false;
    _currentPage = 1;
  }
}

// Mixin for widgets that use API state managers
mixin ApiStateManagerMixin<T extends StatefulWidget> on State<T> {
  final Map<String, ApiStateManager> _stateManagers = {};

  // Get or create state manager
  ApiStateManager<U> getStateManager<U>(String key) {
    return _stateManagers.putIfAbsent(key, () => ApiStateManager<U>()) as ApiStateManager<U>;
  }

  // Get or create list state manager
  ListApiStateManager<U> getListStateManager<U>(String key) {
    return _stateManagers.putIfAbsent(key, () => ListApiStateManager<U>()) as ListApiStateManager<U>;
  }

  // Get or create paginated state manager
  PaginatedApiStateManager<U> getPaginatedStateManager<U>(String key, {int pageSize = 20}) {
    return _stateManagers.putIfAbsent(key, () => PaginatedApiStateManager<U>(pageSize: pageSize)) as PaginatedApiStateManager<U>;
  }

  @override
  void dispose() {
    // Dispose all state managers
    for (final manager in _stateManagers.values) {
      manager.dispose();
    }
    _stateManagers.clear();
    super.dispose();
  }
}

// Helper function to execute API calls with error handling
Future<T?> executeApiCall<T>(
  Future<T> Function() apiCall, {
  Function(String error, ErrorType errorType)? onError,
  Function(T data)? onSuccess,
}) async {
  try {
    final result = await apiCall();
    onSuccess?.call(result);
    return result;
  } catch (e) {
    final errorType = e is ApiException 
        ? _determineErrorTypeFromException(e)
        : ErrorType.unknown;
    onError?.call(e.toString(), errorType);
    return null;
  }
}

ErrorType _determineErrorTypeFromException(ApiException exception) {
  final message = exception.message.toLowerCase();
  
  if (message.contains('network') || message.contains('connection')) {
    return ErrorType.network;
  } else if (message.contains('timeout')) {
    return ErrorType.timeout;
  } else if (message.contains('unauthorized') || message.contains('401')) {
    return ErrorType.authentication;
  } else if (message.contains('forbidden') || message.contains('403')) {
    return ErrorType.permission;
  } else if (message.contains('not found') || message.contains('404')) {
    return ErrorType.notFound;
  } else if (message.contains('validation') || message.contains('400')) {
    return ErrorType.validation;
  } else if (message.contains('server') || message.contains('500')) {
    return ErrorType.server;
  }
  
  return ErrorType.unknown;
}
