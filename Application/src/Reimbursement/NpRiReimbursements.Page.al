page 6151102 "NPR NpRi Reimbursements"
{
    // NPR5.44/MHA /20180723  CASE 320133 Object Created - NaviPartner Reimbursement
    // NPR5.46/MHA /20181002  CASE 323942 Set DelayedInsert to Yes
    // NPR5.54/JKL /20191213  CASE 382066 New field 310 Deactivated added
    // NPR5.54/BHR /20200306  CASE 385924 Add fields 315, 316

    Caption = 'Reimbursements';
    DelayedInsert = true;
    PageType = List;
    RefreshOnActivate = true;
    SourceTable = "NPR NpRi Reimbursement";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Party Type"; "Party Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Party Type field';
                }
                field("Party No."; "Party No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Party No. field';
                }
                field("Template Code"; "Template Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Template Code field';
                }
                field("Data Collection Module"; "Data Collection Module")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Data Collection Module field';
                }
                field("Data Collection Company"; "Data Collection Company")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Data Collection Company field';
                }
                field("Data Collection Summary"; "Data Collection Summary")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Data Collection Summary field';
                }
                field("From Date"; "From Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the From Date field';
                }
                field("To Date"; "To Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the To Date field';
                }
                field("Last Data Collect Entry No."; "Last Data Collect Entry No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Last Data Collect Entry No. field';
                }
                field("Last Data Collection at"; "Last Data Collection at")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Last Data Collection at field';
                }
                field("Reimbursement Module"; "Reimbursement Module")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Reimbursement Module field';
                }
                field("Reimbursement Summary"; "Reimbursement Summary")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Reimbursement Summary field';
                }
                field("Last Posting Date"; "Last Posting Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Last Posting Date field';
                }
                field("Last Reimbursement at"; "Last Reimbursement at")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Last Reimbursement at field';
                }
                field("Reimbursement Date"; "Reimbursement Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Reimbursement Date field';
                }
                field("Posting Date"; "Posting Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Posting Date field';
                }
                field(Balance; Balance)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Balance field';
                }
                field(Deactivated; Deactivated)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Deactivated field';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Run Data Collection")
            {
                Caption = 'Run Data Collection';
                Image = ExecuteBatch;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Run Data Collection action';

                trigger OnAction()
                var
                    NpRiReimbursement: Record "NPR NpRi Reimbursement";
                    NpRiDataCollectionMgt: Codeunit "NPR NpRi Data Collection Mgt.";
                begin
                    CurrPage.SetSelectionFilter(NpRiReimbursement);
                    NpRiDataCollectionMgt.RunDataCollections(NpRiReimbursement);
                    CurrPage.Update;
                end;
            }
            action("Run Reimbursement")
            {
                Caption = 'Run Reimbursement';
                Image = ExecuteAndPostBatch;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Run Reimbursement action';

                trigger OnAction()
                var
                    NpRiReimbursement: Record "NPR NpRi Reimbursement";
                    NpRiReimbursementMgt: Codeunit "NPR NpRi Reimbursement Mgt.";
                begin
                    CurrPage.SetSelectionFilter(NpRiReimbursement);
                    NpRiReimbursementMgt.RunReimbursements(NpRiReimbursement);
                    CurrPage.Update;
                end;
            }
        }
        area(navigation)
        {
            action(Entries)
            {
                Caption = 'Entries';
                Image = List;
                RunObject = Page "NPR NpRi Reimburs. Entries";
                RunPageLink = "Party Type" = FIELD("Party Type"),
                              "Party No." = FIELD("Party No."),
                              "Template Code" = FIELD("Template Code");
                ShortCutKey = 'Ctrl+F7';
                ApplicationArea = All;
                ToolTip = 'Executes the Entries action';
            }
        }
    }
}

