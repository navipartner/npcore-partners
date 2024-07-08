page 6151491 "NPR Raptor Setup"
{
    Extensible = False;
    AccessByPermission = TableData "NPR Raptor Setup" = M;
    Caption = 'Raptor Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "NPR Raptor Setup";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Enable Raptor Functions"; Rec."Enable Raptor Functions")
                {
                    ToolTip = 'Specifies the value of the Enable Raptor Functions field';
                    ApplicationArea = NPRRetail;
                }
                field("Base Url"; Rec."Base Url")
                {
                    ToolTip = 'Specifies the value of the Base Url field';
                    ApplicationArea = NPRRetail;
                }
                field("Customer ID"; Rec."Customer ID")
                {
                    ToolTip = 'Specifies the value of the Customer ID field';
                    ApplicationArea = NPRRetail;
                }
                field("API Key"; Rec."API Key")
                {
                    ToolTip = 'Specifies the value of the API Key field';
                    ApplicationArea = NPRRetail;
                }
            }
            group(Tracking)
            {
                Caption = 'Tracking';
                field("Send Data to Raptor"; Rec."Send Data to Raptor")
                {
                    Enabled = Rec."Enable Raptor Functions";
                    ToolTip = 'Specifies the value of the Send Data to Raptor field';
                    ApplicationArea = NPRRetail;
                }
                field("Tracking Service Url"; Rec."Tracking Service Url")
                {
                    ToolTip = 'Specifies the value of the Tracking Service Url field';
                    ApplicationArea = NPRRetail;
                }
                field("Tracking Service Type"; Rec."Tracking Service Type")
                {
                    ToolTip = 'Specifies the value of the Tracking Service Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Exclude Webshop Sales"; Rec."Exclude Webshop Sales")
                {
                    ToolTip = 'Specifies the value of the Exclude Webshop Sales field';
                    ApplicationArea = NPRRetail;
                }
                field("Webshop Salesperson Filter"; Rec."Webshop Salesperson Filter")
                {
                    Enabled = Rec."Exclude Webshop Sales";
                    ToolTip = 'Specifies the value of the Webshop Salesperson Filter field';
                    ApplicationArea = NPRRetail;

                    trigger OnAssistEdit()
                    var
                        RaptorMgt: Codeunit "NPR Raptor Management";
                        SalespersonFilter: Text;
                    begin
                        SalespersonFilter := Rec."Webshop Salesperson Filter";
                        RaptorMgt.SelectWebShopSalespersons(SalespersonFilter);
                        Rec."Webshop Salesperson Filter" := CopyStr(SalespersonFilter, 1, MaxStrLen(Rec."Webshop Salesperson Filter"));
                    end;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(RaptorActions)
            {
                Caption = 'Set up Raptor Actions';
                Image = XMLSetup;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR Raptor Actions";
                ToolTip = 'Executes the Set up Raptor Actions action';
                ApplicationArea = NPRRetail;
            }
            action(RaptorUrls)
            {
                Caption = 'Reset Urls';
                Image = LinkWeb;
                ToolTip = 'Executes the Reset Urls action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    Rec.InitUrls(true);
                end;
            }
            action(JobQueueEntry)
            {
                Caption = 'Job Queue Entry';
                Enabled = Rec."Send Data to Raptor";
                Image = JobListSetup;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                ToolTip = 'View or edit the job that sends tracking data to Raptor. For example, you can see the status or change when and how often the data is sent.';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    RaptorMgt: Codeunit "NPR Raptor Management";
                begin
                    RaptorMgt.ShowJobQueueEntry();
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        RaptorManagement: Codeunit "NPR Raptor Management";
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert(true);
            RaptorManagement.InitializeDefaultActions(false, false);
        end;
    end;
}
