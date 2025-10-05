import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'country_code_picker.dart';

class AnimatedPhoneField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final String initialCountryCode;

  const AnimatedPhoneField({
    Key? key,
    required this.controller,
    required this.label,
    this.validator,
    this.onChanged,
    this.initialCountryCode = '+254',
  }) : super(key: key);

  @override
  State<AnimatedPhoneField> createState() => _AnimatedPhoneFieldState();
}

class _AnimatedPhoneFieldState extends State<AnimatedPhoneField>
    with TickerProviderStateMixin {
  late AnimationController _focusController;
  late AnimationController _validationController;
  late Animation<double> _focusAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _borderColorAnimation;

  final FocusNode _focusNode = FocusNode();
  bool _isValid = false;
  bool _hasError = false;
  String? _errorText;
  String _countryCode = '+254';

  @override
  void initState() {
    super.initState();
    _countryCode = widget.initialCountryCode;
    
    // Focus animation controller
    _focusController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    // Validation animation controller
    _validationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // Focus listeners
    _focusNode.addListener(_onFocusChange);
    widget.controller.addListener(_onTextChange);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Initialize theme-dependent animations here
    _focusAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _focusController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(CurvedAnimation(
      parent: _focusController,
      curve: Curves.easeInOut,
    ));

    // Color animations
    _borderColorAnimation = ColorTween(
      begin: Colors.grey.shade300,
      end: Theme.of(context).colorScheme.primary,
    ).animate(CurvedAnimation(
      parent: _focusController,
      curve: Curves.easeInOut,
    ));
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      _focusController.forward();
    } else {
      _focusController.reverse();
      _validateInput();
    }
  }

  void _onTextChange() {
    if (widget.onChanged != null) {
      widget.onChanged!(_countryCode + widget.controller.text);
    }
    
    if (_hasError) {
      _validateInput();
    }
  }

  void _validateInput() {
    if (widget.validator != null) {
      final fullPhoneNumber = _countryCode + widget.controller.text;
      final error = widget.validator!(fullPhoneNumber);
      
      setState(() {
        _hasError = error != null;
        _errorText = error;
        _isValid = error == null && widget.controller.text.isNotEmpty;
      });

      if (_hasError) {
        _validationController.forward();
      } else {
        _validationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _focusController.dispose();
    _validationController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AnimatedBuilder(
      animation: Listenable.merge([_focusController, _validationController]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Label
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  widget.label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: _hasError 
                        ? Colors.red 
                        : _focusNode.hasFocus 
                            ? theme.colorScheme.primary 
                            : theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ),
              
              // Phone input field
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: (_focusNode.hasFocus ? theme.colorScheme.primary : Colors.grey)
                          .withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Country code picker
                    CountryCodePicker(
                      initialCountryCode: _countryCode,
                      onCountryCodeChanged: (code) {
                        setState(() {
                          _countryCode = code;
                        });
                        _onTextChange();
                      },
                    ),
                    
                    const SizedBox(width: 12),
                    
                    // Phone number input
                    Expanded(
                      child: TextFormField(
                        controller: widget.controller,
                        focusNode: _focusNode,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(15),
                        ],
                        decoration: InputDecoration(
                          hintText: 'Enter phone number',
                          hintStyle: TextStyle(
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                          filled: true,
                          fillColor: theme.colorScheme.surface,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: _hasError 
                                  ? Colors.red 
                                  : _borderColorAnimation.value ?? Colors.grey.shade300,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: _hasError 
                                  ? Colors.red 
                                  : _borderColorAnimation.value ?? Colors.grey.shade300,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: _hasError ? Colors.red : theme.colorScheme.primary,
                              width: 2,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.red, width: 2),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.red, width: 2),
                          ),
                          suffixIcon: _isValid
                              ? Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                )
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Error message
              if (_hasError && _errorText != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 16,
                        color: Colors.red,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          _errorText!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
