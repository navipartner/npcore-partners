pageextension 6014444 "NPR SalesPriceList" extends "Sales Price List"
{
    layout
    {
        addafter(EndingDate)
        {
            field("NPR Retail Price List"; Rec."NPR Retail Price List")
            {
                ToolTip = 'Specifies the value of the Retail Price List field.';
                ApplicationArea = NPRRetail;
                Visible = RetailLocalizationEnabled;
            }
            field("NPR Location Code"; Rec."NPR Location Code")
            {
                ToolTip = 'Specifies Location Code for Sales Price List';
                ApplicationArea = NPRRetail;
                Visible = RetailLocalizationEnabled;
                Editable = Rec."NPR Retail Price List";
            }
        }
#if (BC17 or BC18 or BC19)
    }
#else
        modify(Status)
        {
            trigger OnAfterValidate()
            begin
                CheckPriceListStatus();
            end;
        }
    }
    actions
    {
        addafter(SuggestLines)
        {
            action("NPR PostNivelation")
            {
                ApplicationArea = NPRRSRLocal;
                Image = Document;
                Caption = 'Post Nivelation Document';
                ToolTip = 'Creates and posts the nivelation document for the current Price List.';

                trigger OnAction()
                var
                    ChangePriceNivelationMgt: Codeunit "NPR RS Change Price Nivelation";
                begin
                    ChangePriceNivelationMgt.CreateAndPostPriceChangeNivelationDocument(Rec);
                end;
            }
            action("NPR Verify Price List")
            {
                ApplicationArea = NPRRSRLocal;
                Image = Confirm;
                Caption = 'Verify Price List';
                ToolTip = 'Sets the current price list status to Active, and sets the ending date of previosly active price lists.';

                trigger OnAction()
                var
                    UpdatePriceList: Codeunit "NPR RS Update Sales Price List";
                    VerifySuccesfullMsg: Label 'Price List is successfully verified.';
                    UnsuccesfullVerifyingErr: Label 'Price List has not been verified successfully.';
                begin
                    if not UpdatePriceList.UpdatePriceListStatus(Rec) then
                        Error(UnsuccesfullVerifyingErr);
                    Message(VerifySuccesfullMsg);
                end;
            }
        }
    }
    local procedure CheckPriceListStatus(): Boolean
    var
        RSRLocalizationMgt: Codeunit "NPR RS R Localization Mgt.";
        CannotChangeActiveStatusErr: Label 'Once Active, you cannot change the price status again.';
    begin
        if not RSRLocalizationMgt.IsRSLocalizationActive() then
            exit;
        if xRec.Status in ["Price Status"::Active] then
            Error(CannotChangeActiveStatusErr);
    end;
#endif
    trigger OnOpenPage()
    var
        RetailLocalizationMgt: Codeunit "NPR Retail Localization Mgt.";
    begin
        RetailLocalizationEnabled := RetailLocalizationMgt.IsRetailLocalizationEnabled();
    end;

    var
        RetailLocalizationEnabled: Boolean;
}