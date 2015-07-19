OUTDIR="$1"
ROOT="/"

class-dump -I -H -o "$OUTDIR/MailUI" "$ROOT/Applications/Mail.app/Contents/MacOS/Mail"
class-dump -I -H -o "$OUTDIR/EmailAddressing" "$ROOT/System/Library/PrivateFrameworks/EmailAddressing.framework/EmailAddressing" 
class-dump -I -H -o "$OUTDIR/MailCore" "$ROOT/System/Library/PrivateFrameworks/MailCore.framework/MailCore"
class-dump -I -H -o "$OUTDIR/MailUIFW" "$ROOT/System/Library/PrivateFrameworks/MailUI.framework"
class-dump -I -H -o "$OUTDIR/MailFW" "$ROOT/System/Library/PrivateFrameworks/Mail.framework"
