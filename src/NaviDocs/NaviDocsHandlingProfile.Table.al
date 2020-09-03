table 6059770 "NPR NaviDocs Handling Profile"
{
    // NPR5.26/THRO/20160808 CASE 248662 Changed table from containing Report Filters to Sending Profile.

    Caption = 'NaviDocs Entry Report Filters';
    DrillDownPageID = "NPR NaviDocs Handling Profiles";
    LookupPageID = "NPR NaviDocs Handling Profiles";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Entry No.';
            NotBlank = true;
        }
        field(10; Description; Text[80])
        {
            Caption = 'Description';
        }
        field(20; "Report Required"; Boolean)
        {
            Caption = 'Report Required';
        }
        field(50; "Handle by NAS"; Boolean)
        {
            Caption = 'Handle by NAS';
        }
        field(100; "Default for Print"; Boolean)
        {
            Caption = 'Print All Containing Entry';

            trigger OnValidate()
            begin
                if "Default for Print" then
                    TestDefaultProfiles(0);
                SetDefaults;
            end;
        }
        field(110; "Default for E-Mail"; Boolean)
        {
            Caption = 'Default for E-Mail';

            trigger OnValidate()
            begin
                if "Default for E-Mail" then
                    TestDefaultProfiles(1);
                SetDefaults;
            end;
        }
        field(120; "Default Electronic Document"; Boolean)
        {
            Caption = 'Default for Electronic Document';

            trigger OnValidate()
            begin
                if "Default Electronic Document" then
                    TestDefaultProfiles(2);
                SetDefaults;
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

    trigger OnInsert()
    begin
        //-NPR5.26 [248662]
        SetDefaults;
        //+NPR5.26 [248662]
    end;

    var
        DefaultProfileWarning: Label 'Profile %1 is designed for %2 only. Changing the setting may result in unexpected behavior.';
        ElectronicDocumentTxt: Label 'Electronic Document';
        PrintTxt: Label 'Print';
        EmailTxt: Label 'E-Mail';

    local procedure SetDefaults()
    var
        NaviDocsHandlingProfile: Record "NPR NaviDocs Handling Profile";
    begin
        //-NPR5.26 [248662]
        if "Default for Print" then begin
            NaviDocsHandlingProfile.SetFilter(Code, '<>%1', Code);
            NaviDocsHandlingProfile.SetRange("Default for Print", true);
            NaviDocsHandlingProfile.ModifyAll("Default for Print", false);
            NaviDocsHandlingProfile.SetRange("Default for Print");
        end;
        if "Default for E-Mail" then begin
            NaviDocsHandlingProfile.SetFilter(Code, '<>%1', Code);
            NaviDocsHandlingProfile.SetRange("Default for E-Mail", true);
            NaviDocsHandlingProfile.ModifyAll("Default for E-Mail", false);
            NaviDocsHandlingProfile.SetRange("Default for E-Mail");
        end;
        if "Default Electronic Document" then begin
            NaviDocsHandlingProfile.SetFilter(Code, '<>%1', Code);
            NaviDocsHandlingProfile.SetRange("Default Electronic Document", true);
            NaviDocsHandlingProfile.ModifyAll("Default Electronic Document", false);
            NaviDocsHandlingProfile.SetRange("Default Electronic Document");
        end;
        //+NPR5.26 [248662]
    end;

    local procedure TestDefaultProfiles(Type: Option Print,"E-Mail","Electronic Document")
    var
        NaviDocsManagement: Codeunit "NPR NaviDocs Management";
    begin
        if (Code = NaviDocsManagement.HandlingTypePrintCode) and ("Default for E-Mail" or "Default Electronic Document") then
            Message(DefaultProfileWarning, Code, PrintTxt);
        if (Code = NaviDocsManagement.HandlingTypeMailCode) and ("Default for Print" or "Default Electronic Document") then
            Message(DefaultProfileWarning, Code, EmailTxt);
        if (Code = NaviDocsManagement.HandlingTypeElecDocCode) and ("Default for E-Mail" or "Default for Print") then
            Message(DefaultProfileWarning, Code, ElectronicDocumentTxt);
    end;
}

