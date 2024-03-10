page 6184472 "NPR SI POS Store Step"
{
    Extensible = False;
    Caption = 'SI POS Payment Method Mapping';
    PageType = ListPart;
    SourceTable = "NPR SI POS Store Mapping";
    SourceTableTemporary = true;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            repeater(POSStoreMappingLines)
            {
                field("POS Store Code"; Rec."POS Store Code")
                {
                    ApplicationArea = NPRSIFiscal;
                    ToolTip = 'Specifies the POS Store Code.';
                }
                field(Registered; Rec.Registered)
                {
                    ApplicationArea = NPRSIFiscal;
                    ToolTip = 'Specifies if the related POS Unit is Registered.';
                }
                field("Cadastral Number"; Rec."Cadastral Number")
                {
                    ApplicationArea = NPRSIFiscal;
                    ToolTip = 'Specifies the Cadastral Number of the related registered POS Unit.';
                }
                field("Building Number"; Rec."Building Number")
                {
                    ApplicationArea = NPRSIFiscal;
                    ToolTip = 'Specifies the Building Number of the related registered POS Unit.';
                }
                field("Building Section Number"; Rec."Building Section Number")
                {
                    ApplicationArea = NPRSIFiscal;
                    ToolTip = 'Specifies the Building Section Number of the related registered POS Unit.';
                }
                field("Validity Date"; Rec."Validity Date")
                {
                    ApplicationArea = NPRSIFiscal;
                    ToolTip = 'Specifies the Validity Date of the registration.';
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(Register)
            {
                Caption = 'Register POS Store';
                Image = Registered;
                ApplicationArea = NPRSIFiscal;
                ToolTip = 'Executes the Register POS Store action.';
                trigger OnAction()
                var
                    SITaxCommunicationMgt: Codeunit "NPR SI Tax Communication Mgt.";
                begin
                    SITaxCommunicationMgt.RegisterPOSStore(Rec);
                end;
            }
        }
    }

    internal procedure CopyRealToTemp()
    begin
        if not SIPOSStoreMapping.FindSet() then
            exit;
        repeat
            Rec.TransferFields(SIPOSStoreMapping);
            if not Rec.Insert() then
                Rec.Modify();
        until SIPOSStoreMapping.Next() = 0;
    end;

    internal procedure SIPOSPaymentMethodMappingDataToCreate(): Boolean
    begin
        exit(CheckIsDataSet());
    end;

    internal procedure CreatePOSPaymMethodMappingData()
    begin
        if not Rec.FindSet() then
            exit;
        repeat
            SIPOSStoreMapping.TransferFields(Rec);
            if not SIPOSStoreMapping.Insert() then
                SIPOSStoreMapping.Modify();
        until Rec.Next() = 0;
    end;

    local procedure CheckIsDataSet(): Boolean
    begin
        if not Rec.FindFirst() then
            exit(false);
        exit(Rec."POS Store Code" <> '');
    end;

    var
        SIPOSStoreMapping: Record "NPR SI POS Store Mapping";
}