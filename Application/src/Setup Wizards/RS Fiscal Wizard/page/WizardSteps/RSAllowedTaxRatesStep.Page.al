page 6151460 "NPR RS Allowed Tax Rates Step"
{
    Caption = 'RS Allowed Tax Rates Step';
    Extensible = false;
    PageType = ListPart;
    SourceTable = "NPR RS Allowed Tax Rates";
    SourceTableTemporary = true;
    UsageCategory = None;


    layout
    {
        area(Content)
        {
            repeater(RSAllowedTaxRates)
            {
                field("Valid From Date"; Rec."Valid From Date")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Valid From Date field.';
                }
                field("Valid From Time"; Rec."Valid From Time")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Valid From Time field.';
                }
                field("Group ID"; Rec."Group ID")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Group ID field.';
                }
                field("Tax Category Name"; Rec."Tax Category Name")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Tax Category Name field.';
                }
                field("Tax Category Type"; Rec."Tax Category Type")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Tax Category Type field.';
                }
                field("Tax Category Rate"; Rec."Tax Category Rate")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Tax Category Rate field.';
                }
                field("Tax Category Rate Label"; Rec."Tax Category Rate Label")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Tax Category Rate Label field.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(PullAllowedTaxRates)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Get Allowed Tax Rates';
                Image = Administration;
                ToolTip = 'Executing this Action, the allowed Tax Rates will be pulled from the Tax Authority.';
                trigger OnAction()
                var
                    RSTaxCommunicationMgt: Codeunit "NPR RS Tax Communication Mgt.";
                begin
                    RSTaxCommunicationMgt.PullAndFillAllowedTaxRates();
                    CopyRealToTemp();
                end;
            }
            action(VATPostingSetup)
            {
                ApplicationArea = NPRRetail;
                Caption = 'VAT Posting Setup';
                Image = SetupPayment;
                RunObject = page "VAT Posting Setup";
                ToolTip = 'Open VAT Posting Setup page';
            }
        }
    }

    internal procedure CopyRealToTemp()
    begin
        if not RSAllowedTaxRates.FindSet() then
            exit;
        repeat
            Rec.TransferFields(RSAllowedTaxRates);
            if not Rec.Insert() then
                Rec.Modify();
        until RSAllowedTaxRates.Next() = 0;
    end;

    internal procedure RSAllowedTaxRatesDataToCreate(): Boolean
    begin
        exit(Rec.FindFirst());
    end;

    internal procedure CreateRSAllowedTaxRatesData()
    begin
        if not Rec.FindSet() then
            exit;
        repeat
            RSAllowedTaxRates.TransferFields(RSAllowedTaxRates);
            if not RSAllowedTaxRates.Insert() then
                RSAllowedTaxRates.Modify();
        until Rec.Next() = 0;
    end;

    var
        RSAllowedTaxRates: Record "NPR RS Allowed Tax Rates";
}
