tableextension 6014443 "NPR Item Cross Reference" extends "Item Cross Reference"
{
    fields
    {
        field(6014440; "NPR Is Retail Serial No."; Boolean)
        {
            ObsoleteState = Pending;
            ObsoleteReason = 'Cross-Reference replaced with Item Reference';
            ObsoleteTag = 'ItemReference.TableExt.al';

            Caption = 'Is Retail Serial No.';
            DataClassification = CustomerContent;
            Description = 'NPR5.47';
        }
        field(6014441; "NPR Time Stamp"; BigInteger)
        {
            ObsoleteState = Removed;
            ObsoleteReason = 'Cross-Reference replaced with Item Reference';
            ObsoleteTag = 'ItemReference.TableExt.al';

            Caption = 'Time Stamp';
            DataClassification = CustomerContent;
        }
    }
}

