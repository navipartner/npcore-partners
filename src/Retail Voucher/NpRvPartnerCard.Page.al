page 6151027 "NPR NpRv Partner Card"
{
    // NPR5.49/MHA /20190228  CASE 342811 Object created - Retail Voucher Partner used with Cross Company Vouchers

    Caption = 'Retail Voucher Partner';
    PageType = Card;
    UsageCategory = Administration;
    SourceTable = "NPR NpRv Partner";

    layout
    {
        area(content)
        {
            group(General)
            {
                group(Control6014407)
                {
                    ShowCaption = false;
                    field("Code"; Code)
                    {
                        ApplicationArea = All;
                        ShowMandatory = true;
                    }
                    field(Name; Name)
                    {
                        ApplicationArea = All;
                    }
                }
                group(Control6014408)
                {
                    ShowCaption = false;
                    field("Service Url"; "Service Url")
                    {
                        ApplicationArea = All;
                        ShowMandatory = true;
                    }
                    field("Service Username"; "Service Username")
                    {
                        ApplicationArea = All;
                        ShowMandatory = true;
                    }
                    field("Service Password"; "Service Password")
                    {
                        ApplicationArea = All;
                        ShowMandatory = true;
                    }
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Validate Partner Setup")
            {
                Caption = 'Validate Partner Setup';
                Image = Approve;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;

                trigger OnAction()
                var
                    NpRvPartnerMgt: Codeunit "NPR NpRv Partner Mgt.";
                begin
                    if NpRvPartnerMgt.TryValidateGlobalVoucherService(Rec) then
                        Message(Text001)
                    else
                        Error(GetLastErrorText);
                end;
            }
        }
    }

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        NpRvPartnerMgt: Codeunit "NPR NpRv Partner Mgt.";
    begin
        if not NpRvPartnerMgt.TryValidateGlobalVoucherService(Rec) then
            exit(Confirm(Text000, false));
    end;

    var
        Text000: Label 'Error in Partner Setup\\Close anway?';
        Text001: Label 'Partner Setup validated successfully';
}

