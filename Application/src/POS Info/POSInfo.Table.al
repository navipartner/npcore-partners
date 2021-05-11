table 6150640 "NPR POS Info"
{
    Caption = 'POS Info';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR POS Info List";
    LookupPageID = "NPR POS Info List";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(2; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(5; "Message"; Text[50])
        {
            Caption = 'Message';
            DataClassification = CustomerContent;
        }
        field(10; Type; Option)
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Show Message,Request Data,Write Default Message';
            OptionMembers = "Show Message","Request Data","Write Default Message";
        }
        field(20; "Input Type"; Option)
        {
            Caption = 'Input Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Text,SubCode,Table';
            OptionMembers = Text,SubCode,"Table";
        }
        field(21; "Table No."; Integer)
        {
            Caption = 'Table No.';
            DataClassification = CustomerContent;
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table));
        }
        field(30; "Input Mandatory"; Boolean)
        {
            Caption = 'Input Mandatory';
            DataClassification = CustomerContent;
        }
        field(40; "Once per Transaction"; Boolean)
        {
            Caption = 'Once per Transaction';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "Once per Transaction" then begin
                    "Copy from Header" := false;
                    "Set POS Sale Line Color to Red" := false;
                end;
            end;
        }
        field(50; "Copy from Header"; Boolean)
        {
            Caption = 'Copy from Header';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestField("Once per Transaction", false);
            end;
        }
        field(60; "Available in Front-End"; Boolean)
        {
            Caption = 'Available in Front-End';
            DataClassification = CustomerContent;
        }
        field(70; "Set POS Sale Line Color to Red"; Boolean)
        {
            Caption = 'Set POS Sale Line Color to Red';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestField("Once per Transaction", false);
            end;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        POSInfoSubcode: Record "NPR POS Info Subcode";
        POSInfoLinkTable: Record "NPR POS Info Link Table";
        POSInfoLookupSetup: Record "NPR POS Info Lookup Setup";
    begin
        POSInfoLinkTable.SetRange("POS Info Code", Rec.Code);
        if POSInfoLinkTable.FindFirst() then
            if not Confirm(StrSubstNo(ConfText001, Rec.TableCaption), true) then
                Error(ErrText001);

        POSInfoSubcode.SetRange(Code, Rec.Code);
        POSInfoSubcode.DeleteAll();

        POSInfoLinkTable.SetRange("POS Info Code", Code);
        POSInfoLinkTable.DeleteAll();

        POSInfoLookupSetup.SetRange("POS Info Code", Code);
        POSInfoLookupSetup.DeleteAll();
    end;

    var
        ConfText001: Label 'Deleting this %1 will delete all instances where it is used, continue?';
        ErrText001: Label 'Cancelled by user.';
}
