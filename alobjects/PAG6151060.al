page 6151060 "Distribution Plan"
{
    // NPR5.38.01/JKL /20180126  CASE 289017 Object created - Replenishment Module

    AutoSplitKey = true;
    Caption = 'Distribution Plan';
    PageType = ListPlus;
    SourceTable = "Distribution Headers";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Distribution Group";"Distribution Group")
                {
                }
                field("Item Hiearachy";"Item Hiearachy")
                {
                }
                field("Distribution Type";"Distribution Type")
                {
                }
                field(Description;Description)
                {
                }
                field(View;View)
                {
                    Caption = 'View';
                    Visible = false;
                }
                field("Required Date";"Required Date")
                {
                }
            }
            part(DistMatrix;"Distribution Matrix")
            {
                SubPageLink = "Item Hierarchy Code"=FIELD("Item Hiearachy");
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

                trigger OnAction()
                var
                    DistributionMgmt: Codeunit "Distribution Mgmt";
                    ItemHierarchy: Record "Item Hierarchy";
                    DistributionGroups: Record "Distribution Group";
                begin
                    ItemHierarchy.Get("Item Hiearachy");
                    DistributionGroups.Get("Distribution Group");
                    DistributionMgmt.CreateDistributionItem("Distribution Id",ItemHierarchy,DistributionGroups);
                end;
            }
            action("Create Distribution Orders")
            {
                Caption = 'Create Distribution Orders';
                Image = CreateDocument;
                Promoted = true;

                trigger OnAction()
                var
                    DistributionMgmt: Codeunit "Distribution Mgmt";
                    ItemHierarchy: Record "Item Hierarchy";
                    DistributionGroups: Record "Distribution Group";
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
                RunObject = Page "Distribution Orders";
                RunPageLink = "Distribution Id"=FIELD("Distribution Id"),
                              "Distribution Item"=CONST('<>'''),
                              "Distribution Quantity"=FILTER(>0);
            }
            action("Import Demands")
            {
                Caption = 'Import Demands';
                Image = ImportDatabase;
                Promoted = true;
                Visible = false;

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
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ToolTip = 'Previous Set';

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
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ToolTip = 'Previous Set';

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
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ToolTip = 'Next Set';

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
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ToolTip = 'Next Set';

                    trigger OnAction()
                    var
                        LastColumn: Integer;
                    begin
                        //Next Set
                        LastColumn := CurrPage.DistMatrix.PAGE.GetLastColumnShown;
                        //IF LastColumn < 12 THEN
                        //  LastColumn := 0
                        //ELSE
                          LastColumn :=  12 ;
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

