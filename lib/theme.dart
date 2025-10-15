import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF2E1065);
  static const Color secondaryColor = Color(0xFFFFB347);
  static const Color deepPrimary = Color(0xFF3B0764);
  static const Color deepSecondary = Color(0xFFE69536);

  static const Color darkPurple = Color(0xFF191825);
  static const Color primaryPurple = Color(0xFF865DFF);

  static final ThemeData owlLightTheme = ThemeData(
    colorScheme: ColorSchemes.lightOrange.copyWith(
      primary: () => primaryColor,
      secondary: () => secondaryColor,
    ),
    radius: 0.5,
    typography: Typography(
      sans: GoogleFonts.poppins(),
      mono: GoogleFonts.poppins(),
      xSmall: GoogleFonts.poppins(fontSize: 10),
      small: GoogleFonts.poppins(fontSize: 12),
      base: GoogleFonts.poppins(fontSize: 14),
      large: GoogleFonts.poppins(fontSize: 16),
      xLarge: GoogleFonts.poppins(fontSize: 18),
      x2Large: GoogleFonts.poppins(fontSize: 20),
      x3Large: GoogleFonts.poppins(fontSize: 24),
      x4Large: GoogleFonts.poppins(fontSize: 28),
      x5Large: GoogleFonts.poppins(fontSize: 32),
      x6Large: GoogleFonts.poppins(fontSize: 36),
      x7Large: GoogleFonts.poppins(fontSize: 40),
      x8Large: GoogleFonts.poppins(fontSize: 48),
      x9Large: GoogleFonts.poppins(fontSize: 56),
      thin: GoogleFonts.poppins(fontWeight: FontWeight.w100),
      extraLight: GoogleFonts.poppins(fontWeight: FontWeight.w200),
      light: GoogleFonts.poppins(fontWeight: FontWeight.w300),
      normal: GoogleFonts.poppins(fontWeight: FontWeight.w400),
      medium: GoogleFonts.poppins(fontWeight: FontWeight.w500),
      semiBold: GoogleFonts.poppins(fontWeight: FontWeight.w600),
      bold: GoogleFonts.poppins(fontWeight: FontWeight.w700),
      extraBold: GoogleFonts.poppins(fontWeight: FontWeight.w800),
      black: GoogleFonts.poppins(fontWeight: FontWeight.w900),
      italic: GoogleFonts.poppins(fontStyle: FontStyle.italic),
      h1: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold),
      h2: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w600),
      h3: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w500),
      h4: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w500),
      p: GoogleFonts.poppins(fontSize: 14),
      blockQuote: GoogleFonts.poppins(
        fontSize: 14,
        fontStyle: FontStyle.italic,
      ),
      inlineCode: GoogleFonts.poppins().copyWith(fontFamily: "monospace"),
      lead: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w400),
      textLarge: GoogleFonts.poppins(fontSize: 18),
      textSmall: GoogleFonts.poppins(fontSize: 12),
      textMuted: GoogleFonts.poppins(color: const Color(0xFF888888)),
    ),
  );

  static final ThemeData owlDarkTheme = ThemeData(
    colorScheme: ColorSchemes.darkOrange.copyWith(
      primary: () => primaryColor,
      secondary: () => secondaryColor,
    ),
    radius: 0.5,
    typography: Typography(
      sans: GoogleFonts.poppins(color: const Color(0xFFFFFFFF)),
      mono: GoogleFonts.poppins(color: const Color(0xFFFFFFFF)),
      xSmall: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFFDDDDDD)),
      small: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFFCCCCCC)),
      base: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFFCCCCCC)),
      large: GoogleFonts.poppins(fontSize: 16, color: const Color(0xFFEEEEEE)),
      xLarge: GoogleFonts.poppins(fontSize: 18, color: const Color(0xFFFFFFFF)),
      x2Large: GoogleFonts.poppins(
        fontSize: 20,
        color: const Color(0xFFFFFFFF),
      ),
      x3Large: GoogleFonts.poppins(
        fontSize: 24,
        color: const Color(0xFFFFFFFF),
      ),
      x4Large: GoogleFonts.poppins(
        fontSize: 28,
        color: const Color(0xFFFFFFFF),
      ),
      x5Large: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: const Color(0xFFFFFFFF),
      ),
      x6Large: GoogleFonts.poppins(
        fontSize: 36,
        color: const Color(0xFFFFFFFF),
      ),
      x7Large: GoogleFonts.poppins(
        fontSize: 40,
        color: const Color(0xFFFFFFFF),
      ),
      x8Large: GoogleFonts.poppins(
        fontSize: 48,
        color: const Color(0xFFFFFFFF),
      ),
      x9Large: GoogleFonts.poppins(
        fontSize: 56,
        color: const Color(0xFFFFFFFF),
      ),
      thin: GoogleFonts.poppins(
        fontWeight: FontWeight.w100,
        color: const Color(0xFFCCCCCC),
      ),
      extraLight: GoogleFonts.poppins(
        fontWeight: FontWeight.w200,
        color: const Color(0xFFCCCCCC),
      ),
      light: GoogleFonts.poppins(
        fontWeight: FontWeight.w300,
        color: const Color(0xFFCCCCCC),
      ),
      normal: GoogleFonts.poppins(
        fontWeight: FontWeight.w400,
        color: const Color(0xFFFFFFFF),
      ),
      medium: GoogleFonts.poppins(
        fontWeight: FontWeight.w500,
        color: const Color(0xFFFFFFFF),
      ),
      semiBold: GoogleFonts.poppins(
        fontWeight: FontWeight.w600,
        color: const Color(0xFFFFFFFF),
      ),
      bold: GoogleFonts.poppins(
        fontWeight: FontWeight.w700,
        color: const Color(0xFFFFFFFF),
      ),
      extraBold: GoogleFonts.poppins(
        fontWeight: FontWeight.w800,
        color: const Color(0xFFFFFFFF),
      ),
      black: GoogleFonts.poppins(
        fontWeight: FontWeight.w900,
        color: const Color(0xFFFFFFFF),
      ),
      italic: GoogleFonts.poppins(
        fontStyle: FontStyle.italic,
        color: const Color(0xFFFFFFFF),
      ),
      h1: GoogleFonts.poppins(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: const Color(0xFFFFFFFF),
      ),
      h2: GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: const Color(0xFFFFFFFF),
      ),
      h3: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w500,
        color: const Color(0xFFFFFFFF),
      ),
      h4: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: const Color(0xFFFFFFFF),
      ),
      p: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFFDDDDDD)),
      blockQuote: GoogleFonts.poppins(
        fontSize: 14,
        fontStyle: FontStyle.italic,
        color: const Color(0xFFBBBBBB),
      ),
      inlineCode: GoogleFonts.poppins(
        color: const Color(0xFFFFFFFF),
      ).copyWith(fontFamily: "monospace"),
      lead: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: const Color(0xFFCCCCCC),
      ),
      textLarge: GoogleFonts.poppins(
        fontSize: 18,
        color: const Color(0xFFFFFFFF),
      ),
      textSmall: GoogleFonts.poppins(
        fontSize: 12,
        color: const Color(0xFFAAAAAA),
      ),
      textMuted: GoogleFonts.poppins(color: const Color(0xFF888888)),
    ),
  );
}
