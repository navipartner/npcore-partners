page 6151024 "NPR NpRv Global Voucher Setup"
{
    // NPR5.42/MHA /20180521  CASE 307022 Object created - Global Retail Voucher for tenant; guldsmeddirks
    // NPR5.49/MHA /20190228  CASE 342811 Added Retail Voucher Partner functionality used with Cross Company Vouchers

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
                    }
                    field("Service Url"; "Service Url")
                    {
                        ApplicationArea = All;
                        ShowMandatory = true;
                    }
                    field("Service Username"; "Service Username")
                    {
                        ApplicationArea = All;
                    }
                    field("Service Password"; "Service Password")
                    {
                        ApplicationArea = All;
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
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;

                trigger OnAction()
                var
                    NpRvModuleValidateGlobal: Codeunit "NPR NpRv Module Valid.: Global";
                begin
                    //-NPR5.49 [342811]
                    if NpRvModuleValidateGlobal.TryValidateGlobalVoucherSetup(Rec) then
                        Message(Text001)
                    else
                        Error(GetLastErrorText);
                    //+NPR5.49 [342811]
                end;
            }
        }
    }

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        NpRvModuleValidateGlobal: Codeunit "NPR NpRv Module Valid.: Global";
    begin
        //-NPR5.49 [342811]
        if not NpRvModuleValidateGlobal.TryValidateGlobalVoucherSetup(Rec) then
            exit(Confirm(Text000, false));
        //+NPR5.49 [342811]
    end;

    var
        Text000: Label 'Error in Global Voucher Setup\\Close anway?';
        Text001: Label 'Global Voucher Setup validated successfully';
}

