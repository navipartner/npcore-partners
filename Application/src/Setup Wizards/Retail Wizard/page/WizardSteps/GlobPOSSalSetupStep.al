page 6014682 "NPR Glob. POS Sal. Setup Step"
{
    Caption = 'Global POS Sales Setup';
    PageType = ListPart;
    SourceTable = "NPR NpGp POS Sales Setup";
    SourceTableTemporary = true;
    DelayedInsert = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    ShowMandatory = true;

                    trigger OnValidate()
                    begin
                        CheckIfNoAvailableInNpGlobalPOSSalesSetup(ExistingNpGlobalPOSSalesSetup, Rec.Code);
                    end;
                }
                field("Company Name"; Rec."Company Name")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    var
                        Company: Record Company;
                        NpGpPOSSalesSyncMgt: Codeunit "NPR NpGp POS Sales Sync Mgt.";
                        Url: Text;
                    begin
                        if StrLen(Rec."Company Name") > MaxStrlen(Company.Name) then
                            exit;
                        if not Company.get(Rec."Company Name") then
                            exit;

                        NpGpPOSSalesSyncMgt.InitGlobalPosSalesService();
                        Url := GetUrl(ClientType::SOAP, Company.Name, ObjectType::Codeunit, Codeunit::"NPR NpGp POS Sales WS");
                        Rec."Service Url" := CopyStr(Url, 1, MaxStrlen(Rec."Service Url"));
                    end;
                }
                field("Service Url"; Rec."Service Url")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        CopyReal();
    end;

    var
        ExistingNpGlobalPOSSalesSetup: Record "NPR NpGp POS Sales Setup" temporary;

    procedure GetRec(var TempGlobalPOSSalesSetup: Record "NPR NpGp POS Sales Setup")
    begin
        TempGlobalPOSSalesSetup.Copy(Rec);
    end;

    procedure CreateNpGlobalPOSSalesSetupData()
    var
        NpGlobalPOSSalesSetup: Record "NPR NpGp POS Sales Setup";
    begin
        if Rec.FindSet() then
            repeat
                NpGlobalPOSSalesSetup := Rec;
                if not NpGlobalPOSSalesSetup.Insert() then
                    NpGlobalPOSSalesSetup.Modify();
            until Rec.Next() = 0;
    end;

    procedure GlobalPOSSalesSetupDataToCreate(): Boolean
    begin
        exit(Rec.FindSet());
    end;

    procedure CopyRealAndTemp(var TempGlobalPOSSalesSetup: Record "NPR NpGp POS Sales Setup")
    var
        GlobalPOSSalesSetup: Record "NPR NpGp POS Sales Setup";
    begin
        TempGlobalPOSSalesSetup.DeleteAll();
        if Rec.FindSet() then
            repeat
                TempGlobalPOSSalesSetup := Rec;
                TempGlobalPOSSalesSetup.Insert();
            until Rec.Next() = 0;

        TempGlobalPOSSalesSetup.Init();
        if GlobalPOSSalesSetup.FindSet() then
            repeat
                TempGlobalPOSSalesSetup.TransferFields(GlobalPOSSalesSetup);
                TempGlobalPOSSalesSetup.Insert();
            until GlobalPOSSalesSetup.Next() = 0;
    end;

    local procedure CopyReal()
    var
        NpGlobalPOSSalesSetup: Record "NPR NpGp POS Sales Setup";
    begin
        if NpGlobalPOSSalesSetup.FindSet() then
            repeat
                ExistingNpGlobalPOSSalesSetup := NpGlobalPOSSalesSetup;
                ExistingNpGlobalPOSSalesSetup.Insert();
            until NpGlobalPOSSalesSetup.Next() = 0;
    end;

    local procedure CheckIfNoAvailableInNpGlobalPOSSalesSetup(var NpGlobalPOSSalesSetup: Record "NPR NpGp POS Sales Setup"; var WantedStartingNo: Code[10]) CalculatedNo: Code[10]
    var
        HelperFunctions: Codeunit "NPR Wizard Helper Functions";
    begin
        CalculatedNo := WantedStartingNo;

        NpGlobalPOSSalesSetup.SetRange(Code, CalculatedNo);

        if NpGlobalPOSSalesSetup.FindFirst() then begin
            HelperFunctions.FormatCode(WantedStartingNo, true);
            CalculatedNo := CheckIfNoAvailableInNpGlobalPOSSalesSetup(NpGlobalPOSSalesSetup, WantedStartingNo);
        end;
    end;
}