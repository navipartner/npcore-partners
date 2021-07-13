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
                    field("Service Company Name"; Rec."Service Company Name")
                    {

                        ToolTip = 'Specifies the value of the Service Company Name field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Service Url"; Rec."Service Url")
                    {

                        ShowMandatory = true;
                        ToolTip = 'Specifies the value of the Service Url field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Service Username"; Rec."Service Username")
                    {

                        ToolTip = 'Specifies the value of the Service Username field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Service Password"; Rec."Service Password")
                    {

                        ExtendedDatatype = Masked;
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
            action("Validate Global Voucher Setup")
            {
                Caption = 'Validate Global Voucher Setup';
                Image = Approve;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip = 'Executes the Validate Global Voucher Setup action';
                ApplicationArea = NPRRetail;

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

