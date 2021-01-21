page 6060082 "NPR MCS Recomm. Model Card"
{
    // NPR5.30/BR  /20170215  CASE 252646 Object Created

    Caption = 'MCS Recommendations Model Card';
    PageType = Card;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR MCS Recomm. Model";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field("Build Status"; "Build Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Build Status field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field(Enabled; Enabled)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Enabled field';
                }
            }
            group(MCS)
            {
                field("Model ID"; "Model ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Model ID field';
                }
                field("Last Build ID"; "Last Build ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Last Build ID field';
                }
                field("Last Build Date Time"; "Last Build Date Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Last Build Date Time field';
                }
                field("Last Catalog Export Date Time"; "Last Catalog Export Date Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Last Catalog Export Date Time field';
                }
                field("Last Item Ledger Entry No."; "Last Item Ledger Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Last Item Ledger Entry No. field';

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        if Confirm(TextResetItemLedgerEntry) then
                            "Last Item Ledger Entry No." := 0;
                    end;
                }
            }
            group("Export Settings")
            {
                field("Item View"; "Item View")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item View field';
                }
                field("Attribute View"; "Attribute View")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Attribute View field';
                }
                field("Customer View"; "Customer View")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer View field';
                }
                field("Item Ledger Entry View"; "Item Ledger Entry View")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item Ledger Entry View field';
                }
                field(Categories; Categories)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Categories field';
                }
                field("Language Code"; "Language Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Language Code field';
                }
                field("Recommendations per Seed"; "Recommendations per Seed")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Recommendations per Seed field';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group("Preview")
            {
                Caption = 'Preview';
                action(PreviewCatalog)
                {
                    Caption = 'Catalog';
                    Image = PreviewChecks;
                    Promoted = true;
				    PromotedOnly = true;
                    PromotedCategory = "Report";
                    ApplicationArea = All;
                    ToolTip = 'Executes the Catalog action';

                    trigger OnAction()
                    var
                        MCRRecBuildModelData: Codeunit "NPR MCS Rec. Build Model Data";
                    begin
                        MCRRecBuildModelData.PreviewDataToSend(0, Rec);
                    end;
                }
                action(PreviewHistory)
                {
                    Caption = 'Sales History';
                    Image = ViewWorksheet;
                    Promoted = true;
				    PromotedOnly = true;
                    PromotedCategory = "Report";
                    PromotedIsBig = true;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Sales History action';

                    trigger OnAction()
                    var
                        MCRRecBuildModelData: Codeunit "NPR MCS Rec. Build Model Data";
                    begin
                        MCRRecBuildModelData.PreviewDataToSend(1, Rec);
                    end;
                }
            }
            group(Maintain)
            {
                Caption = 'Maintain';
                action(CreateAzureModel)
                {
                    Caption = 'Create Azure Model';
                    Image = CreateXMLFile;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Create Azure Model action';
                    //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedCategory = Process;
                    //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedIsBig = true;

                    trigger OnAction()
                    var
                        MCRRecBuildModelData: Codeunit "NPR MCS Rec. Build Model Data";
                    begin
                        MCRRecBuildModelData.CreateRecommendationsModel(Rec);
                    end;
                }
                action(UploadUsageData)
                {
                    Caption = 'Upload Sales History';
                    Image = Server;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Upload Sales History action';
                    //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedCategory = Process;

                    trigger OnAction()
                    var
                        MCRRecBuildModelData: Codeunit "NPR MCS Rec. Build Model Data";
                    begin
                        MCRRecBuildModelData.UploadUsageData(Rec);
                    end;
                }
                action(GetRecommendations)
                {
                    Caption = 'Test Get Recommendations';
                    Image = Task;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Test Get Recommendations action';
                    //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedCategory = Process;
                    //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedIsBig = true;

                    trigger OnAction()
                    var
                        MCRRecBuildModelData: Codeunit "NPR MCS Rec. Build Model Data";
                    begin
                        MCRRecBuildModelData.TestGetRecommendations(Rec, '40010');
                    end;
                }
                action(GetRecommendationsAllItems)
                {
                    Caption = 'Refresh All Recommendations';
                    Image = RefreshLines;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Refresh All Recommendations action';

                    trigger OnAction()
                    var
                        MCSRecommendationsHandler: Codeunit "NPR MCS Recomm. Handler";
                    begin
                        MCSRecommendationsHandler.RefreshRecommendations(Rec, true);
                    end;
                }
                action(DeleteAzureModel)
                {
                    Caption = 'Delete Azure Model';
                    Image = Delete;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Delete Azure Model action';
                    //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedCategory = Process;
                    //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedIsBig = true;

                    trigger OnAction()
                    var
                        MCRRecBuildModelData: Codeunit "NPR MCS Rec. Build Model Data";
                    begin
                        MCRRecBuildModelData.DeleteModel(Rec);
                    end;
                }
            }
        }
        area(navigation)
        {
            action(BusinessRules)
            {
                Caption = 'Business Rules';
                Image = DefaultFault;
                Promoted = true;
				PromotedOnly = true;
                PromotedCategory = Process;
                RunObject = Page "NPR MCS Rec. Business Rules";
                RunPageLink = "Model No." = FIELD(Code);
                RunPageView = SORTING("Model No.", "Rule No.")
                              ORDER(Ascending);
                ApplicationArea = All;
                ToolTip = 'Executes the Business Rules action';
            }
            action(RecommendationsLines)
            {
                Caption = 'RecommendationsLines';
                Image = SuggestLines;
                RunObject = Page "NPR MCS Recomm. Lines";
                RunPageLink = "Model No." = FIELD(Code);
                ApplicationArea = All;
                ToolTip = 'Executes the RecommendationsLines action';
            }
            action(Log)
            {
                Caption = 'Log';
                Image = InteractionLog;
                RunObject = Page "NPR MCS Recommendations Log";
                RunPageLink = "Model No." = FIELD(Code);
                ApplicationArea = All;
                ToolTip = 'Executes the Log action';
            }
        }
    }

    var
        TextResetItemLedgerEntry: Label 'Do you want to reset the Item Ledger Entry counter (all history will be sent again)?';
}

