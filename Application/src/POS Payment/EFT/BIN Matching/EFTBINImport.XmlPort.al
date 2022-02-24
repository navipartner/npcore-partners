xmlport 6184500 "NPR EFT BIN Import"
{
    Caption = 'Teller BIN Import';
    Direction = Import;
    FieldSeparator = ';';
    Format = VariableText;
    TextEncoding = UTF16;

    schema
    {
        textelement("<binrange>")
        {
            XmlName = 'BINRange';
            tableelement("EFT BIN Range"; "NPR EFT BIN Range")
            {
                XmlName = 'EFTBINRange';
                UseTemporary = true;
                fieldelement(BINfrom; "EFT BIN Range"."BIN from")
                {
                }
                fieldelement(BINto; "EFT BIN Range"."BIN to")
                {
                }
                fieldelement(BINGroupCode; "EFT BIN Range"."BIN Group Code")
                {
                }
                textelement(BINGroupDescription)
                {
                }
                textelement(Priority)
                {
                }

                trigger OnAfterInsertRecord()
                begin
                    CreateBINGroup();
                end;
            }
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                field("Delete Ranges"; DeleteRanges)
                {
                    Caption = 'Delete existing BIN ranges';

                    ToolTip = 'Specifies the value of the Delete existing BIN ranges field';
                    ApplicationArea = NPRRetail;
                }
                field("Delete Groups"; DeleteGroups)
                {
                    Caption = 'Delete existing BIN groups';

                    ToolTip = 'Specifies the value of the Delete existing BIN groups field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    trigger OnPostXmlPort()
    var
        EFTBinRange: Record "NPR EFT BIN Range";
    begin
        if "EFT BIN Range".FindSet() then
            repeat
                TempEFTBINGroup.Get("EFT BIN Range"."BIN Group Code");
                EFTBinRange.Init();
                EFTBinRange."BIN from" := "EFT BIN Range"."BIN from";
                EFTBinRange."BIN to" := "EFT BIN Range"."BIN to";
                EFTBinRange.Validate("BIN Group Code", "EFT BIN Range"."BIN Group Code");
                if not EFTBinRange.Insert() then
                    EFTBinRange.Modify();
            until "EFT BIN Range".Next() = 0;
    end;

    trigger OnPreXmlPort()
    var
        EFTBINGroup: Record "NPR EFT BIN Group";
        EFTBINRange: Record "NPR EFT BIN Range";
    begin
        if DeleteGroups then
            EFTBINGroup.DeleteAll();
        if DeleteRanges then
            EFTBINRange.DeleteAll();

        if EFTBINGroup.FindSet() then
            repeat
                TempEFTBINGroup := EFTBINGroup;
                TempEFTBINGroup.Insert();
            until EFTBINGroup.Next() = 0;
    end;

    var
        TempEFTBINGroup: Record "NPR EFT BIN Group" temporary;
        DeleteRanges: Boolean;
        DeleteGroups: Boolean;

    local procedure CreateBINGroup()
    var
        EFTBinGroup: Record "NPR EFT BIN Group";
    begin
        if not TempEFTBINGroup.Get("EFT BIN Range"."BIN Group Code") then begin
            EFTBinGroup.Init();
            EFTBinGroup.Code := "EFT BIN Range"."BIN Group Code";
            EFTBinGroup.Description := BINGroupDescription;
            Evaluate(EFTBinGroup.Priority, Priority);
            EFTBinGroup.Insert();

            TempEFTBINGroup := EFTBinGroup;
            TempEFTBINGroup.Insert();
        end;
    end;
}

