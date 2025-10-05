import 'package:flutter/material.dart';

class AnimatedTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData? prefixIcon;
  final bool obscureText;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final VoidCallback? onTap;
  final bool readOnly;
  final int? maxLines;

  const AnimatedTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.prefixIcon,
    this.obscureText = false,
    this.validator,
    this.keyboardType,
    this.onTap,
    this.readOnly = false,
    this.maxLines = 1,
  });

  @override
  State<AnimatedTextField> createState() => _AnimatedTextFieldState();
}

class _AnimatedTextFieldState extends State<AnimatedTextField>
    with TickerProviderStateMixin {
  late AnimationController _focusController;
  late AnimationController _validationController;
  late Animation<double> _focusAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _borderColorAnimation;
  late Animation<Color?> _validationColorAnimation;

  final FocusNode _focusNode = FocusNode();
  bool _hasError = false;
  bool _isValid = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();

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

    _validationColorAnimation = ColorTween(
      begin: Colors.transparent,
      end: Colors.red,
    ).animate(CurvedAnimation(
      parent: _validationController,
      curve: Curves.easeInOut,
    ));
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      _focusController.forward();
    } else {
      _focusController.reverse();
      _validateField();
    }
  }

  void _onTextChange() {
    if (_hasError) {
      _validateField();
    }
  }

  void _validateField() {
    if (widget.validator != null) {
      final error = widget.validator!(widget.controller.text);
      setState(() {
        _hasError = error != null;
        _isValid = error == null && widget.controller.text.isNotEmpty;
        _errorText = error;
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
    // Define black-blue color
    final blackBlueColor = const Color(0xFF1A1B2E);

    return AnimatedBuilder(
      animation: Listenable.merge([_focusController, _validationController]),
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Label above field
              if (widget.labelText.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 8),
                  child: Text(
                    widget.labelText,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14), // Increased by 15%
                  boxShadow: _focusNode.hasFocus
                      ? [
                          BoxShadow(
                            color: theme.colorScheme.primary.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: TextFormField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  obscureText: widget.obscureText,
                  keyboardType: widget.keyboardType,
                  onTap: widget.onTap,
                  readOnly: widget.readOnly,
                  maxLines: widget.maxLines,
                  decoration: InputDecoration(
                    hintText: widget.labelText,
                    prefixIcon: widget.prefixIcon != null
                        ? AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            child: Icon(
                              widget.prefixIcon,
                              size: 28, // Huge icons - increased from 32 to 48
                              color: _hasError
                                  ? Colors.red
                                  : _focusNode.hasFocus
                                      ? theme.colorScheme.primary
                                      : Colors.grey.shade400,
                            ),
                          )
                        : null,
                    suffixIcon: _isValid
                        ? AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            child: const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 24,
                            ),
                          )
                        : _hasError
                            ? AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                child: const Icon(
                                  Icons.error,
                                  color: Colors.red,
                                  size: 24,
                                ),
                              )
                            : null,
                    // Remove all borders
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: blackBlueColor, // Black-blue background
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                  ),
                  validator: widget.validator,
                ),
              ),
              // Animated error message
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: _hasError ? 20 : 0,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: _hasError ? 1.0 : 0.0,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 4, top: 4),
                    child: Text(
                      _errorText ?? '',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
