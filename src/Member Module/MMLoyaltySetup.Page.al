page 6060105 "NPR MM Loyalty Setup"
{
    // MM1.17/TSA/20161214  CASE 243075 Member Point System
    // MM1.19/TSA/20170525  CASE 278061 Handling issues reported by OMA
    // MM1.23/TSA /20171025 CASE 257011 Added fields "Amount Factor", "Point Rate"
    // MM1.37/TSA /20190227 CASE 343053 Expire points functionality
    // MM1.38/TSA /20190425 CASE 338215 Added Loyalty Point Server setups
    // MM1.40/TSA /20190816 CASE 361664 Added field "Auto Upgrade Point Source" and Action to "Auto Upgrade Point Threshold" page
    // MM1.43/TSA /20200203 CASE 388058 Adde expire points at calculation for "as you go"

    Caption = 'Loyalty Setup';
    PageType = List;
    SourceTable = "NPR MM Loyalty Setup";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Collection Period"; "Collection Period")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        //-MM1.37 [343053]
                        CurrPage.Update(true);
                        //+MM1.37 [343053]
                    end;
                }
                field("Fixed Period Start"; "Fixed Period Start")
                {
                    ApplicationArea = All;
                    Style = Attention;
                    StyleExpr = PeriodCalculationIssue;

                    trigger OnValidate()
                    begin
                        //-MM1.37 [343053]
                        CurrPage.Update(true);
                        //+MM1.37 [343053]
                    end;
                }
                field("Collection Period Length"; "Collection Period Length")
                {
                    ApplicationArea = All;
                    Style = Attention;
                    StyleExpr = PeriodCalculationIssue;

                    trigger OnValidate()
                    begin
                        //-MM1.37 [343053]
                        CurrPage.Update(true);
                        //+MM1.37 [343053]
                    end;
                }
                field("Expire Uncollected Points"; "Expire Uncollected Points")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        //-MM1.37 [343053]
                        CurrPage.Update(true);
                        //+MM1.37 [343053]
                    end;
                }
                field("Expire Uncollected After"; "Expire Uncollected After")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        //-MM1.37 [343053]
                        CurrPage.Update(true);
                        //+MM1.37 [343053]
                    end;
                }
                field(TestDate; TestDate)
                {
                    ApplicationArea = All;
                    Caption = 'Period Test Date';
                    Visible = false;

                    trigger OnValidate()
                    var
                        LoyaltyPointManagement: Codeunit "NPR MM Loyalty Point Mgt.";
                    begin
                        //-MM1.37 [343053]
                        LoyaltyPointManagement.CalcultatePointsValidPeriod(Rec, TestDate, CollectionPeriodStart, CollectionPeriodEnd);
                        CurrPage.Update(true);
                        //+MM1.37 [343053]
                    end;
                }
                field(CollectionPeriodStart; CollectionPeriodStart)
                {
                    ApplicationArea = All;
                    Caption = 'Earn Period Start';
                    Editable = false;
                }
                field(CollectionPeriodEnd; CollectionPeriodEnd)
                {
                    ApplicationArea = All;
                    Caption = 'Earn Period End';
                    Editable = false;
                }
                field(ExpirePointsAt; ExpirePointsAt)
                {
                    ApplicationArea = All;
                    Caption = 'Expire Points At';
                    Editable = false;
                }
                field("Voucher Point Source"; "Voucher Point Source")
                {
                    ApplicationArea = All;
                }
                field("Voucher Point Threshold"; "Voucher Point Threshold")
                {
                    ApplicationArea = All;
                }
                field("Voucher Creation"; "Voucher Creation")
                {
                    ApplicationArea = All;
                }
                field("Point Base"; "Point Base")
                {
                    ApplicationArea = All;
                }
                field("Amount Base"; "Amount Base")
                {
                    ApplicationArea = All;
                }
                field("Points On Discounted Sales"; "Points On Discounted Sales")
                {
                    ApplicationArea = All;
                }
                field("Amount Factor"; "Amount Factor")
                {
                    ApplicationArea = All;
                }
                field("Point Rate"; "Point Rate")
                {
                    ApplicationArea = All;
                }
                field("Auto Upgrade Point Source"; "Auto Upgrade Point Source")
                {
                    ApplicationArea = All;
                }
                field(ReasonText; ReasonText)
                {
                    ApplicationArea = All;
                    Caption = 'ReasonText';
                    Editable = false;
                    Style = Attention;
                    StyleExpr = PeriodCalculationIssue;
                    Visible = false;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("Points to Amount Setup")
            {
                Caption = 'Points to Amount Setup';
                Ellipsis = true;
                Image = LineDiscount;
                Promoted = true;
                PromotedIsBig = true;
                RunObject = Page "NPR MM Loyalty Point Setup";
                RunPageLink = Code = FIELD(Code);
            }
            action("Item Points Setup")
            {
                Caption = 'Item Points Setup';
                Ellipsis = true;
                Image = CalculateInvoiceDiscount;
                Promoted = true;
                PromotedIsBig = true;
                RunObject = Page "NPR MM Loy. Item Point Setup";
                RunPageLink = Code = FIELD(Code);
            }
            separator(Separator6014432)
            {
            }
            action("Auto Upgrade Thresholds")
            {
                Caption = 'Auto Upgrade Threshold';
                Image = UserCertificate;
                Promoted = true;
                PromotedIsBig = true;
                RunObject = Page "NPR MM Loyalty Alter Members.";
                RunPageLink = "Loyalty Code" = FIELD(Code);
            }
            group("Cross Company Loyalty")
            {
                Caption = 'Cross Company Loyalty';
                action("(Server) Loyalty Server - Store Setup")
                {
                    Caption = '(Server) Loyalty Server - Store Setup';
                    Image = Server;
                    RunObject = Page "NPR MM Loy. Store Setup Server";
                }
                action("(Client) Loyalty Server Endpoints")
                {
                    Caption = '(Client) Loyalty Server Endpoints';
                    Image = Server;
                    RunObject = Page "NPR MM NPR Endpoint Setup";
                }
                action("(Client) Loyalty Server - Store Setup")
                {
                    Caption = '(Client) Loyalty Server - Store Setup';
                    Image = NumberSetup;
                    RunObject = Page "NPR MM Loy. Store Setup Client";
                }
            }
        }
        area(processing)
        {
            action("Expire Points")
            {
                Caption = 'Expire Points';
                Ellipsis = true;
                Image = Excise;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = Process;
                //The property 'PromotedIsBig' can only be set if the property 'Promoted' is set to 'true'
                //PromotedIsBig = true;

                trigger OnAction()
                begin

                    ExpirePoints();
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        LoyaltyPointManagement: Codeunit "NPR MM Loyalty Point Mgt.";
    begin

        //-MM1.37 [343053]
        CollectionPeriodEnd := 0D;
        CollectionPeriodStart := 0D;
        ReasonText := '';
        if (Rec."Collection Period" = Rec."Collection Period"::FIXED) then begin
            LoyaltyPointManagement.CalcultatePointsValidPeriod(Rec, TestDate, CollectionPeriodStart, CollectionPeriodEnd);

            ExpirePointsAt := 0D;
            if ("Expire Uncollected Points") then
                if (Format("Expire Uncollected After") <> '') then
                    if (CollectionPeriodEnd <> 0D) then
                        ExpirePointsAt := CalcDate("Expire Uncollected After", CollectionPeriodEnd);

            PeriodCalculationIssue := not LoyaltyPointManagement.ValidateFixedPeriodCalculation(Rec, ReasonText);
        end;
        //+MM1.37 [343053]

        //-MM1.43 [388058]
        if (Rec."Collection Period" = Rec."Collection Period"::AS_YOU_GO) then begin
            if ("Expire Uncollected Points") then
                if (Format("Expire Uncollected After") <> '') then
                    ExpirePointsAt := CalcDate("Expire Uncollected After", Today);
        end;
        //+MM1.43 [388058]
    end;

    trigger OnInit()
    begin
        TestDate := Today;
    end;

    var
        CollectionPeriodStart: Date;
        CollectionPeriodEnd: Date;
        ExpirePointsAt: Date;
        TestDate: Date;
        DF_PROBLEM_PREV: Label 'Check your dateformulas - the previous period is not calculating correctly.';
        DF_PROBLEM_NEXT: Label 'Check your dateformulas - the next period is not calculating correctly.';
        PeriodCalculationIssue: Boolean;
        ReasonText: Text;

    local procedure ExpirePoints()
    var
        LoyaltyPointManagement: Codeunit "NPR MM Loyalty Point Mgt.";
    begin

        LoyaltyPointManagement.ExpireFixedPeriodPoints(Rec.Code);
    end;
}

