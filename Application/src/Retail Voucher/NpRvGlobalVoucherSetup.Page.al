page 6151024 "NPR NpRv Global Voucher Setup"
{
    UsageCategory = None;
    Caption = 'Global Voucher Setup';
    InsertAllowed = false;
    SourceTable = "NPR NpRv Global Vouch. Setup";

    layout
    {
        area(content)
        {
            group(General)
            {
                group(Control6014407)
                {
                    ShowCaption = false;
                    field("Service Company Name"; "Service Company Name")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Service Company Name field';
                    }
                    field("Service Url"; "Service Url")
                    {
                        ApplicationArea = All;
                        ShowMandatory = true;
                        ToolTip = 'Specifies the value of the Service Url field';
                    }
                    field("Service Username"; "Service Username")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Service Username field';
                    }
                    field("Service Password"; "Service Password")
                    {
                        ApplicationArea = All;
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
            action("Validate Global Voucher Setup")
            {
                Caption = 'Validate Global Voucher Setup';
                Image = Approve;
                Promoted = true;
				PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Validate Global Voucher Setup action';

                trigger OnAction()
                var
                    NpRvModuleValidateGlobal: Codeunit "NPR NpRv Module Valid.: Global";
                begin
                    if NpRvModuleValidateGlobal.TryValidateGlobalVoucherSetup(Rec) then
                        Message(Text001)
                    else
                        Error(GetLastErrorText);
                end;
            }
        }
    }

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        NpRvModuleValidateGlobal: Codeunit "NPR NpRv Module Valid.: Global";
    begin
        if not NpRvModuleValidateGlobal.TryValidateGlobalVoucherSetup(Rec) then
            exit(Confirm(Text000, false));
    end;

    var
        Text000: Label 'Error in Global Voucher Setup\\Close anway?';
        Text001: Label 'Global Voucher Setup validated successfully';
}

