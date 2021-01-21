page 6151027 "NPR NpRv Partner Card"
{
    Caption = 'Retail Voucher Partner';
    PageType = Card;
    UsageCategory = Administration;
    ApplicationArea = All;
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
                        ToolTip = 'Specifies the value of the Code field';
                    }
                    field(Name; Name)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Name field';
                    }
                }
                group(Control6014408)
                {
                    ShowCaption = false;
                    field("Service Url"; "Service Url")
                    {
                        ApplicationArea = All;
                        ShowMandatory = true;
                        ToolTip = 'Specifies the value of the Service Url field';
                    }
                    field("Service Username"; "Service Username")
                    {
                        ApplicationArea = All;
                        ShowMandatory = true;
                        ToolTip = 'Specifies the value of the Service Username field';
                    }
                    field("Service Password"; "Service Password")
                    {
                        ApplicationArea = All;
                        ShowMandatory = true;
                        ToolTip = 'Specifies the value of the Service Password field';
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
                ApplicationArea = All;
                ToolTip = 'Executes the Validate Partner Setup action';

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

