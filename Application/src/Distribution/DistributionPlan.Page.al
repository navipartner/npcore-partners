page 6151060 "NPR Distribution Plan"
{
    // NPR5.38.01/JKL /20180126  CASE 289017 Object created - Replenishment Module

    AutoSplitKey = true;
    Caption = 'Distribution Plan';
    PageType = ListPlus;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Distribution Headers";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Distribution Group"; "Distribution Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Distribution Group field';
                }
                field("Item Hiearachy"; "Item Hiearachy")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item Hiearachy field';
                }
                field("Distribution Type"; "Distribution Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Distribution Type field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field(View; View)
                {
                    ApplicationArea = All;
                    Caption = 'View';
                    Visible = false;
                    ToolTip = 'Specifies the value of the View field';
                }
                field("Required Date"; "Required Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Required Date field';
                }
            }
            part(DistMatrix; "NPR Distrib. Matrix")
            {
                SubPageLink = "Item Hierarchy Code" = FIELD("Item Hiearachy");
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Create Distribution Proposal")
            {
                Caption = 'Create Distribution';
                Image = CalculateInventory;
                Promoted = true;
				PromotedOnly = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Create Distribution action';

                trigger OnAction()
                var
                    DistributionMgmt: Codeunit "NPR Distribution Mgmt";
                    ItemHierarchy: Record "NPR Item Hierarchy";
                    DistributionGroups: Record "NPR Distrib. Group";
                begin
                    ItemHierarchy.Get("Item Hiearachy");
                    DistributionGroups.Get("Distribution Group");
                    DistributionMgmt.CreateDistributionItem("Distribution Id", ItemHierarchy, DistributionGroups);
                end;
            }
            action("Create Distribution Orders")
            {
                Caption = 'Create Distribution Orders';
                Image = CreateDocument;
                Promoted = true;
				PromotedOnly = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Create Distribution Orders action';

                trigger OnAction()
                var
                    DistributionMgmt: Codeunit "NPR Distribution Mgmt";
                    ItemHierarchy: Record "NPR Item Hierarchy";
                    DistributionGroups: Record "NPR Distrib. Group";
                    CompletedText: Label 'Documents Created!';
                begin
                    ItemHierarchy.Get("Item Hiearachy");
                    DistributionGroups.Get("Distribution Group");
                    DistributionMgmt.CreateDistributionDocuments(Rec);
                    Message(CompletedText);
                end;
            }
            action("View  Documents")
            {
                Caption = 'View Documents';
                Image = CreateDocument;
                Promoted = true;
				PromotedOnly = true;
                RunObject = Page "NPR Distribution Orders";
                RunPageLink = "Distribution Id" = FIELD("Distribution Id"),
                              "Distribution Item" = CONST('<>'''),
                              "Distribution Quantity" = FILTER(> 0);
                ApplicationArea = All;
                ToolTip = 'Executes the View Documents action';
            }
            action("Import Demands")
            {
                Caption = 'Import Demands';
                Image = ImportDatabase;
                Promoted = true;
				PromotedOnly = true;
                Visible = false;
                ApplicationArea = All;
                ToolTip = 'Executes the Import Demands action';

                trigger OnAction()
                var
                    ErrorText: Label 'Demands must be imported from Campaigns/Blanket/forecasts!';
                begin
                    Message(ErrorText);
                end;
            }
            group(Locations)
            {
                Caption = 'Locations';
                action("Previous Set")
                {
                    Caption = 'Previous Set';
                    Image = PreviousSet;
                    Promoted = true;
				    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ToolTip = 'Previous Set';
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        LastColumn: Integer;
                    begin
                        //Previous Set
                        LastColumn := CurrPage.DistMatrix.PAGE.GetLastColumnShown;
                        if LastColumn - 12 < 0 then
                            LastColumn := 0
                        else
                            LastColumn := 0;
                        CurrPage.DistMatrix.PAGE.SetLastColumnShown(LastColumn);
                        CurrPage.DistMatrix.PAGE.Load(Rec);
                    end;
                }
                action("Previous Column")
                {
                    Caption = 'Previous Column';
                    Image = PreviousRecord;
                    Promoted = true;
				    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ToolTip = 'Previous Set';
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        LastColumn: Integer;
                    begin
                        //Previous Column
                        LastColumn := CurrPage.DistMatrix.PAGE.GetLastColumnShown;
                        if LastColumn - 1 < 0 then
                            LastColumn := 0
                        else
                            LastColumn := LastColumn - 1;
                        CurrPage.DistMatrix.PAGE.SetLastColumnShown(LastColumn);
                        CurrPage.DistMatrix.PAGE.Load(Rec);
                    end;
                }
                action("Next Column")
                {
                    Caption = 'Next Column';
                    Image = NextRecord;
                    Promoted = true;
				    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ToolTip = 'Next Set';
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        LastColumn: Integer;
                    begin
                        //Next Column
                        LastColumn := CurrPage.DistMatrix.PAGE.GetLastColumnShown;
                        if LastColumn < 0 then
                            LastColumn := 0
                        else
                            LastColumn := LastColumn + 1;
                        CurrPage.DistMatrix.PAGE.SetLastColumnShown(LastColumn);
                        CurrPage.DistMatrix.PAGE.Load(Rec);
                        // MATRIX_GenerateColumnCaptions(MATRIX_Step::NextColumn);
                        // UpdateMatrixSubForm;
                    end;
                }
                action("Next Set")
                {
                    Caption = 'Next Set';
                    Image = NextSet;
                    Promoted = true;
				    PromotedOnly = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ToolTip = 'Next Set';
                    ApplicationArea = All;

                    trigger OnAction()
                    var
                        LastColumn: Integer;
                    begin
                        //Next Set
                        LastColumn := CurrPage.DistMatrix.PAGE.GetLastColumnShown;
                        //IF LastColumn < 12 THEN
                        //  LastColumn := 0
                        //ELSE
                        LastColumn := 12;
                        CurrPage.DistMatrix.PAGE.SetLastColumnShown(LastColumn);
                        CurrPage.DistMatrix.PAGE.Load(Rec);
                        // MATRIX_GenerateColumnCaptions(MATRIX_Step::Next);
                        // UpdateMatrixSubForm;
                    end;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        CurrPage.DistMatrix.PAGE.Load(Rec);
    end;

    trigger OnOpenPage()
    begin
        CurrPage.DistMatrix.PAGE.SetLastColumnShown(0);
    end;

    var
        View: Option Distributions,Demands,Inventory;
        FirstColumn: Integer;
}

