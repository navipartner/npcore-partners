tableextension 6014475 "NPR Responsibility Center" extends "Responsibility Center"
{
    fields
    {
        field(6014475; "NPR Picture"; BLOB)
        {
            Caption = 'Picture';
            DataClassification = CustomerContent;
            SubType = Bitmap;
            ObsoleteState = Removed;
            ObsoleteReason = 'Use Media instead of Blob type. "NPR Responsibility Center"."NPR Picture" -> "NPR Image"';
        }
        field(6014476; "NPR Image"; Media)
        {
            Caption = 'Picture';
            DataClassification = CustomerContent;
        }
    }
}
