import 'package:flutter/material.dart';
import 'dart:html' as html;

import 'package:quickcoat/features/translate_on_hover.dart';


extension HoverExtension on Widget {
  static final appContainer = html.window.document.getElementById('app-container');

  Widget get showCursorOnHover{
    return MouseRegion(child: this,
    onHover: (event)=> appContainer!.style.cursor = 'pointer',
    onExit: (event)=>appContainer!.style.cursor = 'default',);
  }
  Widget get moveUpOnHover{
    return TranslateHover(
      child: this,
    );
  }
}