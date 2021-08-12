page 6151172 "NPR NpGp POS Sales Setup Card"
{
    Caption = 'Global POS Sales Setup Card';
    PageType = Card;
    UsageCategory = Administration;

    SourceTable = "NPR NpGp POS Sales Setup";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                group(Control6014407)
                {
                    ShowCaption = false;
                    field("Code"; Rec.Code)
                    {

                        ToolTip = 'Specifies the value of the Code field';
                        ApplicationArea = NPRRetail;
                    }
                    field(Description; Rec.Description)
                    {

                        ToolTip = 'Specifies the value of the Description field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Company Name"; Rec."Company Name")
                    {

                        ToolTip = 'Specifies the value of the Company Name field';
                        ApplicationArea = NPRRetail;
                    }
                }
                group(Control6014408)
                {
                    ShowCaption = false;
                    field("Service Url"; Rec."Service Url")
                    {

                        ToolTip = 'Specifies the value of the Service Url field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Service Username"; Rec."Service Username")
                    {

                        ToolTip = 'Specifies the value of the Service Username field';
                        ApplicationArea = NPRRetail;
                    }
                    field(Password; Password)
                    {

                        Caption = 'Service Password';
                        ExtendedDatatype = Masked;
                        ToolTip = 'Specifies the value of the Service Password field';
                        ApplicationArea = NPRRetail;

                        trigger OnValidate()
                        begin
                            Rec.HandlePassword(Password);
                        end;
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
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip = 'Executes the Validate Global POS Sales Setup action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    NpGpPOSSalesSyncMgt: Codeunit "NPR NpGp POS Sales Sync Mgt.";
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
    begin
        if not IsNullGuid(Rec."Service Password") then begin
            IsolatedStorage.Get(Rec."Service Password", DataScope::Company, Password);
        end;
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        NpGpPOSSalesSyncMgt: Codeunit "NPR NpGp POS Sales Sync Mgt.";
    begin
        if not NpGpPOSSalesSyncMgt.TryGetGlobalPosSalesService(Rec) then
            exit(Confirm(Text000, false));
    end;

    var
        Text000: Label 'Error in Global POS Sales Setup\\Close anway?';
        Text001: Label 'Global POS Sales Setup validated successfully';
        Password: Text[200];
}

