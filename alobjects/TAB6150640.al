table 6150640 "POS Info"
{
    // NPR5.26/OSFI/20160810 CASE 246167 Object Created
    // NPR5.46/BHR /20180824  CASE 322752 Replace record Object to Allobj -field 21

    Caption = 'POS Info';
    DrillDownPageID = "POS Info List";
    LookupPageID = "POS Info List";

    fields
    {
        field(1;"Code";Code[20])
        {
            Caption = 'Code';
        }
        field(2;Description;Text[50])
        {
            Caption = 'Description';
        }
        field(5;Message;Text[50])
        {
            Caption = 'Message';
        }
        field(10;Type;Option)
        {
            Caption = 'Type';
            OptionCaption = 'Show Message,Request Data';
            OptionMembers = "Show Message","Request Data";
        }
        field(20;"Input Type";Option)
        {
            Caption = 'Input Type';
            OptionCaption = 'Text,SubCode,Table';
            OptionMembers = Text,SubCode,"Table";
        }
        field(21;"Table No.";Integer)
        {
            Caption = 'Table No.';
            TableRelation = AllObj."Object ID" WHERE ("Object Type"=CONST(Table));
        }
        field(30;"Input Mandatory";Boolean)
        {
            Caption = 'Input Mandatory';
        }
        field(40;"Once per Transaction";Boolean)
        {
            Caption = 'Once per Transaction';
        }
    }

    keys
    {
        key(Key1;"Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        POSInfoSubcode: Record "POS Info Subcode";
        POSInfoLinkTable: Record "POS Info Link Table";
        POSInfoLookupSetup: Record "POS Info Lookup Setup";
    begin
        POSInfoLinkTable.SetRange("POS Info Code",Rec.Code);
        if POSInfoLinkTable.FindFirst then
          if not Confirm(StrSubstNo(ConfText001,Rec.TableCaption),true) then
            Error(ErrText001);

        POSInfoSubcode.SetRange(Code,Rec.Code);
        POSInfoSubcode.DeleteAll;

        POSInfoLinkTable.SetRange("POS Info Code",Code);
        POSInfoLinkTable.DeleteAll;

        POSInfoLookupSetup.SetRange("POS Info Code",Code);
        POSInfoLookupSetup.DeleteAll;
    end;

    var
        ConfText001: Label 'Deleting this %1 will delete all instances where it is used, continue?';
        ErrText001: Label 'Cancelled by user.';
}

