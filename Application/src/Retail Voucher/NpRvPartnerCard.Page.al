page 6151027 "NPR NpRv Partner Card"
{
    Caption = 'Retail Voucher Partner';
    PageType = Card;
    UsageCategory = Administration;

    SourceTable = "NPR NpRv Partner";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            group(General)
            {
                group(Control6014407)
                {
                    ShowCaption = false;
                    field("Code"; Rec.Code)
                    {

                        ShowMandatory = true;
                        ToolTip = 'Specifies the value of the Code field';
                        ApplicationArea = NPRRetail;
                    }
                    field(Name; Rec.Name)
                    {

                        ToolTip = 'Specifies the value of the Name field';
                        ApplicationArea = NPRRetail;
                    }
                }
                group(Control6014408)
                {
                    ShowCaption = false;
                    field("Service Url"; Rec."Service Url")
                    {

                        ShowMandatory = true;
                        ToolTip = 'Specifies the value of the Service Url field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Service Username"; Rec."Service Username")
                    {

                        ShowMandatory = true;
                        ToolTip = 'Specifies the value of the Service Username field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Service Password"; Rec."Service Password")
                    {

                        ShowMandatory = true;
                        ToolTip = 'Specifies the value of the Service Password field';
                        ApplicationArea = NPRRetail;
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
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip = 'Executes the Validate Partner Setup action';
                ApplicationArea = NPRRetail;

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

