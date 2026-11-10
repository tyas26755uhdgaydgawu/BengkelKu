// widgets.dart
// Komponen kecil yang dipakai di banyak layar.

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'data.dart';
import 'theme.dart';

TextStyle ts(
  Color c, {
  double size = 14,
  FontWeight w = FontWeight.w400,
  double? h,
  double? ls,
  TextDecoration? deco,
}) =>
    TextStyle(color: c, fontSize: size, fontWeight: w, height: h, letterSpacing: ls, decoration: deco);

/// Layar tablet / laptop (lebar 768 px ke atas).
bool isWide(BuildContext c) => MediaQuery.of(c).size.width >= 768;

// ---------------------------------------------------------------- Chip
class PillChip extends StatelessWidget {
  final String text;
  final Color bg;
  final Color fg;
  const PillChip(this.text, this.bg, this.fg, {super.key});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(99)),
        child: Text(text, style: ts(fg, size: 11, w: FontWeight.w600)),
      );
}

class StatusChip extends StatelessWidget {
  final String status;
  const StatusChip(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    switch (status) {
      case 'menunggu':
        return PillChip('Menunggu', p.warnBg, p.warn);
      case 'diterima':
        return PillChip('Diterima', p.infoBg, p.info);
      case 'dikerjakan':
        return PillChip('Dikerjakan', p.soft, p.softInk);
      case 'selesai':
        return PillChip('Selesai', p.okBg, p.ok);
      case 'ditolak':
        return PillChip('Ditolak', p.badBg, p.bad);
      default:
        return PillChip('Dibatalkan', p.badBg, p.bad);
    }
  }
}

class PayChip extends StatelessWidget {
  final bool paid;
  const PayChip(this.paid, {super.key});

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    return paid ? PillChip('Lunas', p.okBg, p.ok) : PillChip('Belum dibayar', p.warnBg, p.warn);
  }
}

/// Plat nomor motor
class Plate extends StatelessWidget {
  final String text;
  const Plate(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
      decoration: BoxDecoration(color: p.plate, borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: ts(p.onPlate, size: 12, w: FontWeight.w600, ls: 1.2)),
    );
  }
}

// ---------------------------------------------------------------- Kartu & avatar
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color? borderColor;
  final Color? color;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.borderColor,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    final box = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? p.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor ?? p.line, width: borderColor == null ? 1 : 1.5),
      ),
      child: child,
    );
    if (onTap == null) return box;
    return GestureDetector(onTap: onTap, child: box);
  }
}

class Avatar extends StatelessWidget {
  final String letter;
  final double size;
  final Color? bg;
  final Color? fg;
  const Avatar(this.letter, {super.key, this.size = 40, this.bg, this.fg});

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: bg ?? p.soft, shape: BoxShape.circle),
      child: Text(letter, style: ts(fg ?? p.softInk, size: size * 0.4, w: FontWeight.w700)),
    );
  }
}

class IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? bg;
  final Color? fg;
  final bool border;
  const IconBtn(this.icon, this.onTap, {super.key, this.bg, this.fg, this.border = true});

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: bg ?? p.card,
          borderRadius: BorderRadius.circular(12),
          border: border ? Border.all(color: p.line) : null,
        ),
        child: Icon(icon, size: 19, color: fg ?? p.ink),
      ),
    );
  }
}

// ---------------------------------------------------------------- Tombol
enum BtnKind { primary, ghost, soft, bad, outline }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final BtnKind kind;
  final IconData? icon;
  final bool small;

  const AppButton(
    this.label, {
    super.key,
    this.onPressed,
    this.kind = BtnKind.primary,
    this.icon,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    final enabled = onPressed != null;
    final radius = BorderRadius.circular(small ? 11 : 14);
    Color fg = p.ink;
    BoxDecoration deco = const BoxDecoration();
    switch (kind) {
      case BtnKind.primary:
        fg = p.onPrimary;
        deco = BoxDecoration(
          gradient: LinearGradient(
            colors: [p.primary, p.primary2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: radius,
          boxShadow: small
              ? null
              : [BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 10, offset: const Offset(0, 5))],
        );
        break;
      case BtnKind.ghost:
        fg = p.ink;
        deco = BoxDecoration(color: p.card, borderRadius: radius, border: Border.all(color: p.line));
        break;
      case BtnKind.soft:
        fg = p.softInk;
        deco = BoxDecoration(color: p.soft, borderRadius: radius);
        break;
      case BtnKind.bad:
        fg = p.bad;
        deco = BoxDecoration(color: p.badBg, borderRadius: radius);
        break;
      case BtnKind.outline:
        fg = p.softInk;
        deco = BoxDecoration(borderRadius: radius, border: Border.all(color: p.line));
        break;
    }
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          height: small ? 38 : 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: deco,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: small ? 16 : 18, color: fg),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: ts(fg, size: small ? 13 : 15, w: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LinkText extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color? color;
  const LinkText(this.label, this.onTap, {super.key, this.color});

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    return GestureDetector(
      onTap: onTap,
      child: Text(label, style: ts(color ?? p.primary, size: 14, w: FontWeight.w600, deco: TextDecoration.underline)),
    );
  }
}

// ---------------------------------------------------------------- Kolom isian
class UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) =>
      newValue.copyWith(text: newValue.text.toUpperCase());
}

class AppField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboard;
  final TextCapitalization cap;
  final bool uppercase;
  final bool obscure;
  final bool digitsOnly;
  final int? maxLength;
  final ValueChanged<String>? onSubmitted;

  const AppField({
    super.key,
    required this.label,
    required this.controller,
    this.hint = '',
    this.keyboard,
    this.cap = TextCapitalization.none,
    this.uppercase = false,
    this.obscure = false,
    this.digitsOnly = false,
    this.maxLength,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c, width: w),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: ts(p.muted, size: 13, w: FontWeight.w500)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboard,
          textCapitalization: cap,
          maxLength: maxLength,
          onSubmitted: onSubmitted,
          obscureText: obscure,
          inputFormatters: [
            if (uppercase) UpperCaseFormatter(),
            if (digitsOnly) FilteringTextInputFormatter.digitsOnly,
          ],
          style: ts(p.ink, size: 15),
          cursorColor: p.primary,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: ts(p.muted.withOpacity(0.7), size: 15),
            filled: true,
            fillColor: p.card,
            counterText: '',
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 14),
            border: border(p.line),
            enabledBorder: border(p.line),
            focusedBorder: border(p.primary, 1.5),
          ),
        ),
      ],
    );
  }
}

class AppSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const AppSwitch({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 50,
        height: 30,
        padding: const EdgeInsets.all(3),
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        decoration: BoxDecoration(
          color: value ? p.primary : p.line,
          borderRadius: BorderRadius.circular(99),
        ),
        child: Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        ),
      ),
    );
  }
}

/// Pilihan jam (08.00, 09.00, ...) untuk pengaturan jam buka.
class HourPick extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  const HourPick(this.value, this.onChanged, {super.key});

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: value,
        dropdownColor: p.card,
        style: ts(p.ink, size: 14),
        items: [
          for (var h = 6; h <= 22; h++)
            DropdownMenuItem<String>(value: '${pad(h)}:00', child: Text('${pad(h)}.00')),
        ],
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
      ),
    );
  }
}

// ---------------------------------------------------------------- Pilihan (layanan, montir, pembayaran)
class OptTile extends StatelessWidget {
  final bool selected;
  final bool enabled;
  final VoidCallback? onTap;
  final Widget? leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final bool radio;

  const OptTile({
    super.key,
    required this.selected,
    required this.onTap,
    required this.title,
    this.leading,
    this.subtitle,
    this.trailing,
    this.enabled = true,
    this.radio = false,
  });

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected ? p.soft : p.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: selected ? p.primary : p.line, width: 1.5),
          ),
          child: Row(
            children: [
              if (leading != null) ...[leading!, const SizedBox(width: 12)],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [title, if (subtitle != null) subtitle!],
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: 10), trailing!],
              if (radio) ...[
                const SizedBox(width: 10),
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? p.primary : Colors.transparent,
                    border: Border.all(color: selected ? p.primary : p.line, width: 2),
                  ),
                  child: selected ? Icon(Icons.check, size: 12, color: p.onPrimary) : null,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class NoteBox extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final bool soft;
  const NoteBox(this.text, {super.key, this.onTap, this.soft = false});

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    final box = Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        color: soft ? p.soft : p.warnBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: ts(soft ? p.softInk : p.warn, size: 13, w: onTap != null ? FontWeight.w600 : FontWeight.w400),
      ),
    );
    return onTap == null ? box : GestureDetector(onTap: onTap, child: box);
  }
}

/// Kotak pengingat "besok jatah kamu ya!"
class RemindBox extends StatelessWidget {
  final String title;
  final List<Widget> lines;
  final VoidCallback? onTap;
  const RemindBox({super.key, required this.title, required this.lines, this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    final box = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: p.soft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: p.primary, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: p.primary, borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.notifications_none, size: 20, color: p.onPrimary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: ts(p.ink, size: 14, w: FontWeight.w700)),
                const SizedBox(height: 2),
                ...lines,
              ],
            ),
          ),
        ],
      ),
    );
    return onTap == null ? box : GestureDetector(onTap: onTap, child: box);
  }
}

/// Satu baris "label ........ nilai" pada ringkasan.
class KV extends StatelessWidget {
  final String label;
  final String? value;
  final Widget? child;
  final bool last;
  const KV(this.label, {super.key, this.value, this.child, this.last = false});

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: last ? null : Border(bottom: BorderSide(color: p.line)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: ts(p.muted, size: 14)),
          const SizedBox(width: 12),
          Flexible(
            child: Align(
              alignment: Alignment.centerRight,
              child: child ?? Text(value ?? '', textAlign: TextAlign.right, style: ts(p.ink, size: 14, w: FontWeight.w500)),
            ),
          ),
        ],
      ),
    );
  }
}

class ScreenTitle extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;
  const ScreenTitle(this.title, {super.key, this.onBack});

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    return Row(
      children: [
        if (onBack != null) ...[
          IconBtn(Icons.arrow_back_ios_new_rounded, onBack!),
          const SizedBox(width: 10),
        ],
        Expanded(child: Text(title, style: ts(p.ink, size: 20, w: FontWeight.w600, ls: -0.2))),
      ],
    );
  }
}

class StepsBar extends StatelessWidget {
  final int n;
  const StepsBar(this.n, {super.key});

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    const names = ['Layanan', 'Jadwal', 'Montir', 'Pembayaran'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            for (var i = 1; i <= 4; i++) ...[
              if (i > 1) const SizedBox(width: 6),
              Expanded(
                child: Container(
                  height: 5,
                  decoration: BoxDecoration(
                    color: i <= n ? p.primary : p.line,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Text('Langkah $n dari 4 · ${names[n - 1]}', style: ts(p.muted, size: 13)),
      ],
    );
  }
}

/// Pilihan bergaya "segmen" (misal Mendatang | Hari ini | Besok).
class SegBar extends StatelessWidget {
  final List<List<String>> options; // [kunci, label]
  final String value;
  final ValueChanged<String> onChanged;
  const SegBar({super.key, required this.options, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(color: p.line, borderRadius: BorderRadius.circular(13)),
      child: Row(
        children: [
          for (final o in options)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(o[0]),
                child: Container(
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: o[0] == value ? p.card : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    o[1],
                    style: ts(o[0] == value ? p.primary : p.muted, size: 13, w: FontWeight.w600),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class Meter extends StatelessWidget {
  final double value; // 0..1
  const Meter(this.value, {super.key});

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: LinearProgressIndicator(
        value: value.clamp(0.0, 1.0).toDouble(),
        minHeight: 6,
        backgroundColor: p.soft,
        valueColor: AlwaysStoppedAnimation<Color>(p.primary),
      ),
    );
  }
}

/// Menyusun anak-anaknya dalam beberapa kolom sesuai lebar yang tersedia.
class AutoGrid extends StatelessWidget {
  final List<Widget> children;
  final double minWidth;
  final double gap;
  const AutoGrid({super.key, required this.children, this.minWidth = 300, this.gap = 10});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final w = c.maxWidth;
      final cols = math.max(1, math.min(6, ((w + gap) / (minWidth + gap)).floor()));
      final itemW = (w - gap * (cols - 1)) / cols;
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: [for (final e in children) SizedBox(width: itemW, child: e)],
      );
    });
  }
}

// ---------------------------------------------------------------- Kerangka layar
/// Pita berwarna di bagian atas Beranda / Dashboard (kartu putih menimpa pita).
class BandHeader extends StatelessWidget {
  final Widget top; // sapaan
  final Widget card; // kartu yang menimpa pita
  const BandHeader({super.key, required this.top, required this.card});

  @override
  Widget build(BuildContext context) {
    final p = pal(context);
    final wide = isWide(context);
    final radius = wide
        ? BorderRadius.circular(24)
        : const BorderRadius.vertical(bottom: Radius.circular(26));
    return Stack(
      children: [
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          height: 156,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [p.hd1, p.hd2],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: radius,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(wide ? 24 : 18, wide ? 26 : 24, wide ? 24 : 18, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [top, const SizedBox(height: 18), card],
          ),
        ),
      ],
    );
  }
}

/// Kerangka setiap layar: bisa di-scroll, isinya dibatasi lebar maksimal dan diberi jarak.
class ScreenFrame extends StatelessWidget {
  final double maxWidth;
  final Widget? band;
  final List<Widget> children;
  const ScreenFrame({super.key, this.maxWidth = 760, this.band, required this.children});

  List<Widget> _spaced(List<Widget> l) {
    final out = <Widget>[];
    for (var i = 0; i < l.length; i++) {
      if (i > 0) out.add(const SizedBox(height: 14));
      out.add(l[i]);
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final wide = isWide(context);
    final body = Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: _spaced(children));

    // HP: pita memenuhi lebar layar
    if (band != null && !wide) {
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            band!,
            Padding(padding: const EdgeInsets.fromLTRB(18, 14, 18, 28), child: body),
          ],
        ),
      );
    }

    // Tablet / laptop: isi di tengah dengan lebar maksimal
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: wide ? 24 : 18, vertical: wide ? 28 : 20),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (band != null) ...[band!, const SizedBox(height: 14)],
              body,
            ],
          ),
        ),
      ),
    );
  }
}