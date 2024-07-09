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
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Use Media instead of Blob type. "NPR Responsibility Center"."NPR Picture" -> "NPR Image"';
        }
        field(6014476; "NPR Image"; Media)
        {
            Caption = 'Picture';
            DataClassification = CustomerContent;
        }
    }
}
