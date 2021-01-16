page 6151491 "NPR Raptor Setup"
{
    // NPR5.51/CLVA/20190710 CASE 355871 Object created
    // NPR5.53/ALPO/20191125 CASE 377727 Raptor integration enhancements
    // NPR5.53/ALPO/20191128 CASE 379012 Raptor tracking integration: send info about sold products to Raptor
    // NPR5.54/ALPO/20200227 CASE 355871 Possibility to define Raptor tracking service types
    // NPR5.55/ALPO/20200422 CASE 400925 Exclude webshop sales from data sent to Raptor

    AccessByPermission = TableData "NPR Raptor Setup" = M;
    Caption = 'Raptor Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "NPR Raptor Setup";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Enable Raptor Functions"; "Enable Raptor Functions")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Enable Raptor Functions field';
                }
                field("Base Url"; "Base Url")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Base Url field';
                }
                field("Customer ID"; "Customer ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer ID field';
                }
                field("API Key"; "API Key")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the API Key field';
                }
            }
            group(Tracking)
            {
                Caption = 'Tracking';
                field("Send Data to Raptor"; "Send Data to Raptor")
                {
                    ApplicationArea = All;
                    Enabled = "Enable Raptor Functions";
                    ToolTip = 'Specifies the value of the Send Data to Raptor field';
                }
                field("Tracking Service Url"; "Tracking Service Url")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Tracking Service Url field';
                }
                field("Tracking Service Type"; "Tracking Service Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Tracking Service Type field';
                }
                field("Exclude Webshop Sales"; "Exclude Webshop Sales")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Exclude Webshop Sales field';
                }
                field("Webshop Salesperson Filter"; "Webshop Salesperson Filter")
                {
                    ApplicationArea = All;
                    Enabled = "Exclude Webshop Sales";
                    ToolTip = 'Specifies the value of the Webshop Salesperson Filter field';

                    trigger OnAssistEdit()
                    var
                        RaptorMgt: Codeunit "NPR Raptor Management";
                    begin
                        RaptorMgt.SelectWebShopSalespersons("Webshop Salesperson Filter");  //NPR5.55 [400925]
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
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR Raptor Actions";
                ApplicationArea = All;
                ToolTip = 'Executes the Set up Raptor Actions action';
            }
            action(RaptorUrls)
            {
                Caption = 'Reset Urls';
                Image = LinkWeb;
                ApplicationArea = All;
                ToolTip = 'Executes the Reset Urls action';

                trigger OnAction()
                begin
                    InitUrls(true);
                end;
            }
            action(JobQueueEntry)
            {
                Caption = 'Job Queue Entry';
                Enabled = "Send Data to Raptor";
                Image = JobListSetup;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'View or edit the job that sends tracking data to Raptor. For example, you can see the status or change when and how often the data is sent.';
                ApplicationArea = All;

                trigger OnAction()
                var
                    RaptorMgt: Codeunit "NPR Raptor Management";
                begin
                    RaptorMgt.ShowJobQueueEntry;
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
        RaptorManagement: Codeunit "NPR Raptor Management";
    begin
        Reset;
        if not Get then begin
            Init;
            Insert(true);
            RaptorManagement.InitializeDefaultActions(false, false);
        end;
    end;
}

