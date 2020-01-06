page 6151172 "NpGp POS Sales Setup Card"
{
    // NPR5.50/MHA /20190422  CASE 337539 Object created - [NpGp] NaviPartner Global POS Sales
    // NPR5.51/ALST/20190711  CASE 337539 obscured password
    // NPR5.52/ALST/20191009  CASE 372010 added permissions to service password

    Caption = 'Global POS Sales Setup Card';
    PageType = Card;
    Permissions = TableData "Service Password"=rimd;
    SourceTable = "NpGp POS Sales Setup";

    layout
    {
        area(content)
        {
            group(General)
            {
                group(Control6014407)
                {
                    ShowCaption = false;
                    field("Code";Code)
                    {
                    }
                    field("Company Name";"Company Name")
                    {
                    }
                }
                group(Control6014408)
                {
                    ShowCaption = false;
                    field("Service Url";"Service Url")
                    {
                    }
                    field("Service Username";"Service Username")
                    {
                    }
                    field(Password;Password)
                    {
                        Caption = 'Service Password';
                        ExtendedDatatype = Masked;

                        trigger OnValidate()
                        begin
                            //-NPR5.51 [337539]
                            HandlePassword(Password);
                            //+NPR5.51 [337539]
                        end;
                    }
                    field("Sync POS Sales Immediately";"Sync POS Sales Immediately")
                    {
                    }
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Validate Global POS Sales Setup")
            {
                Caption = 'Validate Global POS Sales Setup';
                Image = Approve;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    NpGpPOSSalesSyncMgt: Codeunit "NpGp POS Sales Sync Mgt.";
                begin
                    if NpGpPOSSalesSyncMgt.TryGetGlobalPosSalesService(Rec) then
                      Message(Text001)
                    else
                      Error(GetLastErrorText);
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        ServicePassword: Record "Service Password";
    begin
        //-NPR5.51 [337539]
        if IsNullGuid("Service Password") then
          exit;

        ServicePassword.SetRange(Key,"Service Password");
        ServicePassword.FindFirst;
        Password := ServicePassword.GetPassword;
        //+NPR5.51 [337539]
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        NpGpPOSSalesSyncMgt: Codeunit "NpGp POS Sales Sync Mgt.";
    begin
        if not NpGpPOSSalesSyncMgt.TryGetGlobalPosSalesService(Rec) then
          exit(Confirm(Text000,false));
    end;

    var
        Text000: Label 'Error in Global POS Sales Setup\\Close anway?';
        Text001: Label 'Global POS Sales Setup validated successfully';
        Password: Text;
}

