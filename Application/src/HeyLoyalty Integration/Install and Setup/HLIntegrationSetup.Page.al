page 6150720 "NPR HL Integration Setup"
{
    Extensible = false;
    Caption = 'HeyLoyalty Integration Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "NPR HL Integration Setup";
    UsageCategory = Administration;
    ApplicationArea = NPRHeyLoyalty;
    ContextSensitiveHelpPage = 'heyloyaltyintegration.html';
    PromotedActionCategories = 'New,Process,Report,Initial Setup';

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Enable Integration"; Rec."Enable Integration")
                {
                    ApplicationArea = NPRHeyLoyalty;
                    ToolTip = 'Specifies whether the integration is enabled. This is the master on/off switch for the integration.';

                    trigger OnValidate()
                    begin
                        UpdateControlVisibility();
                    end;
                }
                field("Instant Task Enqueue"; Rec."Instant Task Enqueue")
                {
                    ApplicationArea = NPRHeyLoyalty;
                    Importance = Additional;
                    ToolTip = 'Specifies whether the HeyLoyalty task scheduling routine is executed immediately after a change has been registered in the system. This mode is only allowed on test/sandbox environments.';
                }
                group(MemberListIntegrationArea)
                {
                    Caption = 'Member List Integration Area';
                    field("Member Integration"; Rec."Member Integration")
                    {
                        ApplicationArea = NPRHeyLoyalty;
                        Enabled = IntegrationIsEnabled;
                        ToolTip = 'Specifies whether the Member List integration area is enabled. This will enable member information to be sent to HeyLoyalty.';

                        trigger OnValidate()
                        begin
                            UpdateControlVisibility();
                        end;
                    }
                    field("HeyLoyalty List Id"; Rec."HeyLoyalty Member List Id")
                    {
                        ApplicationArea = NPRHeyLoyalty;
                        Enabled = MemberListIntegrationIsEnabled;
                        ToolTip = 'Specifies the HeyLoyalty member list Id integration is coupled with.';
                    }
                    field("Membership HL Field ID"; Rec."Membership HL Field ID")
                    {
                        ApplicationArea = NPRHeyLoyalty;
                        Enabled = MemberListIntegrationIsEnabled;
                        ToolTip = 'Specifies the field ID at HeyLoyalty for storing information about membership code.';
                    }
                }
            }
            group(Connection)
            {
                Caption = 'Connection Parameters';
                field("HeyLoyalty Api Url"; Rec."HeyLoyalty Api Url")
                {
                    ApplicationArea = NPRHeyLoyalty;
                    ToolTip = 'Specifies the URL for HeyLoyalty Api, for example: https://api.heyloyalty.com/loyalty/v1';
                }
                field("HeyLoyalty Api Key"; Rec."HeyLoyalty Api Key")
                {
                    ApplicationArea = NPRHeyLoyalty;
                    ToolTip = 'Specifies the HeyLoyalty Api Key.';
                }
                field("HeyLoyalty Api Secret"; Rec."HeyLoyalty Api Secret")
                {
                    ApplicationArea = NPRHeyLoyalty;
                    ToolTip = 'Specifies the HeyLoyalty Api Secret.';
                }
            }
        }
    }
    actions
    {
        area(Creation)
        {
            group(InitialSetup)
            {
                Caption = 'Initial Setup';
                action(TestConnection)
                {
                    Caption = 'Test Connection';
                    ToolTip = 'Check if connection parameters are correct, and specified HeyLoyalty member list is accessible.';
                    ApplicationArea = NPRHeyLoyalty;
                    Image = LinkWeb;
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    PromotedCategory = Process;

                    trigger OnAction()
                    var
                        HLIntegrationMgt: Codeunit "NPR HL Integration Mgt.";
                        ResponseJToken: JsonToken;
                        SuccessMsg: Label 'Connection successfully established.';
                    begin
                        if not HLIntegrationMgt.InvokeGetMemberListInfo(ResponseJToken) then
                            Error(GetLastErrorText());
                        Message(SuccessMsg);
                    end;
                }
                action(SyncMembersToHL)
                {
                    Caption = 'Sync. Members';
                    ToolTip = 'Executes intial member synchronization between BC and HeyLoyalty. System will go through members in BC and send synchronization request for each of them to HeyLoyalty.';
                    ApplicationArea = NPRHeyLoyalty;
                    Image = CheckList;
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    PromotedCategory = Category4;

                    trigger OnAction()
                    var
                        Member: Record "NPR MM Member";
                        HLMemberMgt: Codeunit "NPR HL Member Mgt.";
                    begin
                        CurrPage.SaveRecord();
                        HLMemberMgt.DoInitialSync(Member, true);
                    end;
                }
                action(ImportMembersFromFile)
                {
                    Caption = 'Import Members from Excel';
                    ToolTip = 'Import data from an Excel file, containing HeyLoyalty members. System will overwrite existing member data and create new members, if necessary, according to data coming from the file.';
                    ApplicationArea = NPRHeyLoyalty;
                    Image = ImportDatabase;
                    Promoted = true;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    PromotedCategory = Category4;

                    trigger OnAction()
                    begin
                        CurrPage.SaveRecord();
                        Report.Run(Report::"NPR HL Import Members", false);
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
        UpdateControlVisibility();
    end;

    local procedure UpdateControlVisibility()
    begin
        IntegrationIsEnabled := Rec."Enable Integration";
        MemberListIntegrationIsEnabled := Rec."Enable Integration" and Rec."Member Integration";
    end;

    var
        IntegrationIsEnabled: Boolean;
        MemberListIntegrationIsEnabled: Boolean;
}