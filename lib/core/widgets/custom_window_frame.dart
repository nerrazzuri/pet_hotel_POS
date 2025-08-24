import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

/// A custom window frame that can be used within the app structure
/// This avoids Directionality issues by not wrapping the entire MaterialApp
class CustomWindowFrame extends StatefulWidget {
  final Widget child;
  final String title;
  final Color? backgroundColor;
  final Color? titleBarColor;
  final Color? buttonColor;
  final Color? buttonHoverColor;
  final bool showSystemTray;
  final VoidCallback? onMinimizeToTray;

  const CustomWindowFrame({
    super.key,
    required this.child,
    required this.title,
    this.backgroundColor,
    this.titleBarColor,
    this.buttonColor,
    this.buttonHoverColor,
    this.showSystemTray = false,
    this.onMinimizeToTray,
  });

  @override
  State<CustomWindowFrame> createState() => _CustomWindowFrameState();
}

class _CustomWindowFrameState extends State<CustomWindowFrame>
    with WindowListener {
  bool _isMaximized = false;
  bool _isHoveringMinimize = false;
  bool _isHoveringMaximize = false;
  bool _isHoveringClose = false;
  bool _isHoveringMinimizeToTray = false;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _checkWindowState();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  Future<void> _checkWindowState() async {
    final isMaximized = await windowManager.isMaximized();
    if (mounted) {
      setState(() {
        _isMaximized = isMaximized;
      });
    }
  }

  @override
  void onWindowMaximize() {
    if (mounted) {
      setState(() {
        _isMaximized = true;
      });
    }
  }

  @override
  void onWindowUnmaximize() {
    if (mounted) {
      setState(() {
        _isMaximized = false;
      });
    }
  }

  Future<void> _minimizeWindow() async {
    if (widget.showSystemTray && widget.onMinimizeToTray != null) {
      widget.onMinimizeToTray!();
    } else {
      await windowManager.minimize();
    }
  }

  Future<void> _maximizeWindow() async {
    if (_isMaximized) {
      await windowManager.unmaximize();
    } else {
      await windowManager.maximize();
    }
  }

  Future<void> _closeWindow() async {
    await windowManager.close();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: widget.backgroundColor ?? Colors.transparent,
      child: Column(
        children: [
          // Custom Title Bar
          Container(
            height: 32,
            decoration: BoxDecoration(
              color: widget.titleBarColor ?? Colors.grey[900],
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey[700]!,
                  width: 1,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Title (Draggable)
                Expanded(
                  child: DraggableTitleBar(
                    child: Container(
                      padding: const EdgeInsets.only(left: 12),
                      child: Row(
                        children: [
                          // App Icon (optional)
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: const Icon(
                              Icons.pets,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Title Text
                          Text(
                            widget.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Window Control Buttons
                Row(
                  children: [
                    // Minimize to Tray Button (if enabled)
                    if (widget.showSystemTray && widget.onMinimizeToTray != null)
                      _buildWindowButton(
                        icon: Icons.keyboard_arrow_down,
                        onPressed: _minimizeWindow,
                        isHovering: _isHoveringMinimizeToTray,
                        onHover: (hovering) {
                          setState(() {
                            _isHoveringMinimizeToTray = hovering;
                          });
                        },
                        tooltip: 'Minimize to Tray',
                      ),
                    // Minimize Button
                    _buildWindowButton(
                      icon: Icons.remove,
                      onPressed: _minimizeWindow,
                      isHovering: _isHoveringMinimize,
                      onHover: (hovering) {
                        setState(() {
                          _isHoveringMinimize = hovering;
                        });
                      },
                      tooltip: 'Minimize',
                    ),
                    // Maximize/Restore Button
                    _buildWindowButton(
                      icon: _isMaximized ? Icons.crop_square : Icons.crop_free,
                      onPressed: _maximizeWindow,
                      isHovering: _isHoveringMaximize,
                      onHover: (hovering) {
                        setState(() {
                          _isHoveringMaximize = hovering;
                        });
                      },
                      tooltip: _isMaximized ? 'Restore' : 'Maximize',
                    ),
                    // Close Button
                    _buildWindowButton(
                      icon: Icons.close,
                      onPressed: _closeWindow,
                      isHovering: _isHoveringClose,
                      onHover: (hovering) {
                        setState(() {
                          _isHoveringClose = hovering;
                        });
                      },
                      isCloseButton: true,
                      tooltip: 'Close',
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Main Content
          Expanded(child: widget.child),
        ],
      ),
    );
  }

  Widget _buildWindowButton({
    required IconData icon,
    required VoidCallback onPressed,
    required bool isHovering,
    required Function(bool) onHover,
    bool isCloseButton = false,
    String? tooltip,
  }) {
    Color buttonColor = widget.buttonColor ?? Colors.transparent;
    Color hoverColor = widget.buttonHoverColor ?? Colors.grey[800]!;
    
    if (isCloseButton) {
      buttonColor = Colors.transparent;
      hoverColor = Colors.red;
    }

    Widget button = MouseRegion(
      onEnter: (_) => onHover(true),
      onExit: (_) => onHover(false),
      child: GestureDetector(
        onTap: onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 46,
          height: 32,
          decoration: BoxDecoration(
            color: isHovering ? hoverColor : buttonColor,
            borderRadius: BorderRadius.circular(isHovering ? 4 : 0),
          ),
          child: Icon(
            icon,
            size: 16,
            color: isCloseButton && isHovering ? Colors.white : Colors.grey[300],
          ),
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip,
        child: button,
      );
    }

    return button;
  }
}

/// Extension to make the app draggable from the title bar
class DraggableTitleBar extends StatelessWidget {
  final Widget child;

  const DraggableTitleBar({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {
        windowManager.startDragging();
      },
      child: child,
    );
  }
}

/// Alternative approach: A simple custom title bar that can be added to any screen
class CustomTitleBar extends StatelessWidget {
  final String title;
  final Color? backgroundColor;
  final VoidCallback? onMinimize;
  final VoidCallback? onMaximize;
  final VoidCallback? onClose;

  const CustomTitleBar({
    super.key,
    required this.title,
    this.backgroundColor,
    this.onMinimize,
    this.onMaximize,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      color: backgroundColor ?? Colors.grey[900],
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(left: 12),
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          if (onMinimize != null)
            _buildSimpleButton(
              icon: Icons.remove,
              onPressed: onMinimize!,
            ),
          if (onMaximize != null)
            _buildSimpleButton(
              icon: Icons.crop_free,
              onPressed: onMaximize!,
            ),
          if (onClose != null)
            _buildSimpleButton(
              icon: Icons.close,
              onPressed: onClose!,
              isCloseButton: true,
            ),
        ],
      ),
    );
  }

  Widget _buildSimpleButton({
    required IconData icon,
    required VoidCallback onPressed,
    bool isCloseButton = false,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 46,
        height: 32,
        color: Colors.transparent,
        child: Icon(
          icon,
          size: 16,
          color: Colors.grey[300],
        ),
      ),
    );
  }
}
