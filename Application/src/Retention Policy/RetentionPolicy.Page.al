#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24 or BC25)
page 6248216 "NPR Retention Policy"
{
    ApplicationArea = NPRRetail;
    Caption = 'NP Retail Retention Policies';
    DeleteAllowed = false;
    Extensible = False;
    InsertAllowed = false;
    PageType = List;
    SourceTable = "NPR Retention Policy";
    UsageCategory = Administration;
    ContextSensitiveHelpPage = 'docs/retail/retention_policy/explanation/retention_policy/';

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("Table ID"; Rec."Table Id")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the ID of the table to which the retention policy applies.';
                }
                field("Table Name"; Rec."Table Name")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the name of the table to which the retention policy applies.';
                    Visible = false;
                }
                field("Table Caption"; Rec."Table Caption")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the caption of the table to which the retention policy applies. The caption is the translated, if applicable, name of the table.';
                }
                field(Enabled; Rec.Enabled)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies whether the retention policy is enabled.';
                }
                field(Implementation; Rec."Implementation V2")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the codeunit handling the retention of the table.';
                }
            }
        }
    }
    actions
    {
        area(Promoted)
        {
            group(ApplyPolicies)
            {
                Caption = 'Apply Retention Policies';
                ShowAs = SplitButton;
                actionref(PromotedApplySinglePolicyManually; "Apply Single Policy Manually")
                {
                }
                actionref(PromotedApplyAllPoliciesManually; "Apply All Policies Manually")
                {
                }
            }
            actionref(PromotedRetentionPolicyLog; "Retention Policy Log")
            {
            }
            actionref(PromotedShowRetentionPeriodInfo; "Show Retention Period Info")
            {
            }
        }
        area(Processing)
        {
            action("Retention Policy Log")
            {
                ApplicationArea = NPRRetail;
                Caption = 'Retention Policy Log';
                Image = Log;
                RunObject = Page "NPR Reten. Policy Log Entries";
                ToolTip = 'View activity related to retention policies.';
            }
            action("Apply Single Policy Manually")
            {
                ApplicationArea = NPRRetail;
                Caption = 'Apply Policy Manually';
                Image = TestDatabase;
                ToolTip = 'Apply the retention policy to all expired records in the table.';

                trigger OnAction()
                begin
                    RetentionPolicyMgmt.ApplyOneRetentionPolicyManually(Rec);
                end;
            }
            action("Apply All Policies Manually")
            {
                ApplicationArea = NPRRetail;
                Caption = 'Apply All Policies Manually';
                Image = TestDatabase;
                ToolTip = 'Apply all retention policies to expired records in defined tables.';

                trigger OnAction()
                begin
                    RetentionPolicyMgmt.ApplyRetentionPoliciesManually();
                end;
            }
            action("Show Retention Period Info")
            {
                ApplicationArea = NPRRetail;
                Caption = 'Retention Details';
                Image = ShowList;
                ToolTip = 'View information about retention periods of this policy.';

                trigger OnAction()
                var
                    RetentionPolicy: Codeunit "NPR Retention Policy";
                    IRetentionPolicy: Interface "NPR IRetention Policy V2";
                    RetentionPeriodsEditable: Boolean;
                begin
                    RetentionPolicy.OnSetRetentionPolicyPeriodsEditable(RetentionPeriodsEditable);
                    IRetentionPolicy := Rec."Implementation V2";
                    IRetentionPolicy.ShowSetup(Rec, RetentionPeriodsEditable);
                end;
            }
        }
        area(Navigation)
        {
            action("Job Queue Entries")
            {
                AccessByPermission = TableData "Job Queue Entry" = R;
                ApplicationArea = NPRRetail;
                Caption = 'Job Queue Entries';
                Image = TaskPage;
                RunObject = Page "Job Queue Entries";
                RunPageLink = "Object Type to Run" = const(Codeunit),
                              "Object ID to Run" = const(Codeunit::"NPR Retention Policy JQ");
                ToolTip = 'Open the Job Queue Entries page to view NPR Retention Policy job.';
            }
        }
    }

    var
        RetentionPolicyMgmt: Codeunit "NPR Retention Policy Mgmt.";

    trigger OnOpenPage()
    begin
        Rec.DiscoverRetentionPolicyTables();
    end;
}
#endif