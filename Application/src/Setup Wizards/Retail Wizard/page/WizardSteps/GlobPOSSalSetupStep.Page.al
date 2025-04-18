page 6014682 "NPR Glob. POS Sal. Setup Step"
{
    Extensible = False;
    Caption = 'Global POS Sales Setup';
    PageType = ListPart;
    SourceTable = "NPR NpGp POS Sales Setup";
    SourceTableTemporary = true;
    DelayedInsert = true;
    UsageCategory = None;
    ObsoleteState = Pending;
    ObsoleteTag = '2023-06-28';
    ObsoleteReason = 'Not used anymore. Retail wizard was modified.';
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {

                    ShowMandatory = true;
                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;

                    trigger OnValidate()
                    begin
                        CheckIfNoAvailableInNpGlobalPOSSalesSetup(TempExistingNpGlobalPOSSalesSetup, Rec.Code);
                    end;
                }
                field("Company Name"; Rec."Company Name")
                {

                    ToolTip = 'Specifies the value of the Company Name field';
                    ApplicationArea = NPRRetail;

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

                    ToolTip = 'Specifies the value of the Service Url field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        CopyReal();
    end;

    var
        TempExistingNpGlobalPOSSalesSetup: Record "NPR NpGp POS Sales Setup" temporary;

    internal procedure GetRec(var TempGlobalPOSSalesSetup: Record "NPR NpGp POS Sales Setup")
    begin
        TempGlobalPOSSalesSetup.Copy(Rec);
    end;

    internal procedure CreateNpGlobalPOSSalesSetupData()
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

    internal procedure GlobalPOSSalesSetupDataToCreate(): Boolean
    begin
        exit(Rec.FindSet());
    end;

    internal procedure CopyRealAndTemp(var TempGlobalPOSSalesSetup: Record "NPR NpGp POS Sales Setup")
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
                TempExistingNpGlobalPOSSalesSetup := NpGlobalPOSSalesSetup;
                TempExistingNpGlobalPOSSalesSetup.Insert();
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
