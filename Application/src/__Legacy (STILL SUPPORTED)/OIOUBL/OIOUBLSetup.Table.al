table 6059805 "NPR OIOUBL Setup"
{
    ObsoleteState = Pending;
    ObsoleteTag = '2026-01-29';
    ObsoleteReason = 'This module is no longer being maintained';
    Access = Internal;
    Caption = 'OIOUBL Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(2; Enabled; Boolean)
        {
            Caption = 'Enabled';
            DataClassification = CustomerContent;
        }
        field(3; "Filename Pattern"; Text[50])
        {
            Caption = 'Filename Pattern';
            DataClassification = CustomerContent;
            trigger OnValidate()
            var
                InvalidFilenamePatternErr: Label '%1 must contain "%2"', Comment = '%1 - fieldname, %2 - value';
            begin
                if Rec."Filename Pattern" <> '' then
                    if StrPos(Rec."Filename Pattern", '%1') = 0 then
                        Error(InvalidFilenamePatternErr, FieldCaption(Rec."Filename Pattern"), '%1');
            end;
        }
        field(4; "Include PDF Invoice"; Boolean)
        {
            Caption = 'Include PDF Invoice';
            DataClassification = CustomerContent;
        }
        field(5; "Include PDF Cr. Memo"; Boolean)
        {
            Caption = 'Include PDF Cr. Memo';
            DataClassification = CustomerContent;
        }
        field(6; "Use Nemhandel Lookup"; Boolean)
        {
            Caption = 'Use Nemhandel Lookup';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "Code")
        {
            Clustered = true;
        }
    }

    procedure IsOIOUBLInstalled(): Boolean
    var
        AllObjectsWithCaption: Record AllObjWithCaption;
    begin
        AllObjectsWithCaption.SetRange("Object Type", AllObjectsWithCaption."Object Type"::Table);
        AllObjectsWithCaption.SetRange("Object ID", 13630); //table 13630 "OIOUBL-Profile"
        exit(not AllObjectsWithCaption.IsEmpty);
    end;

}
