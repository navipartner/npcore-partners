page 6184570 "NPR RS EI Allowed UOM"
{
    Caption = 'RS E-Invoice Allowed Units Of Measure';
    UsageCategory = None;
    Extensible = false;
    PageType = List;
    SourceTable = "NPR RS EI Allowed UOM";
    Editable = false;
    AdditionalSearchTerms = 'Serbia E-Invoice Allowed Units Of Measure,RS E Invoice Allowed Units Of Measure';

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Code"; Rec.Code)
                {
                    ToolTip = 'Specifies the value of the Code field.';
                    ApplicationArea = NPRRSEInvoice;
                }
                field(Name; Rec.Name)
                {
                    ToolTip = 'Specifies the value of the Name field.';
                    ApplicationArea = NPRRSEInvoice;
                }
                field("Configuration Date"; Rec."Configuration Date")
                {
                    ToolTip = 'Specifies the value of the Configuration Date field.';
                    ApplicationArea = NPRRSEInvoice;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
#if not (BC17 or BC18 or BC19 or BC20 or BC21)
            action(GetAllowedUOMs)
            {
                Caption = 'Get Allowed Unit of Measuers';
                Image = Administration;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Executing this Action, the allowed Units of Measure will be pulled from the E-Invoice API.';
                ApplicationArea = NPRRSEInvoice;

                trigger OnAction()
                var
                    RSEICommunicationMgt: Codeunit "NPR RS EI Communication Mgt.";
                begin
                    RSEICommunicationMgt.GetAllowedUOMs();
                end;
            }
#endif
            action(UOMList)
            {
                Caption = 'Units Of Measure List';
                Image = SetupPayment;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                RunObject = Page "NPR RS EI UOM Mapping";
                ToolTip = 'Open Units of Measure Mapping page';
                ApplicationArea = NPRRSEInvoice;
            }
        }
    }
}