page 6060160 "NPR Event Attribute Templ."
{
    Caption = 'Attribute Templates';
    PageType = List;
    SourceTable = "NPR Event Attribute Template";
    UsageCategory = Lists;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Name; Rec.Name)
                {

                    ToolTip = 'Specifies the value of the Name field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Row Template Name"; Rec."Row Template Name")
                {

                    ToolTip = 'Specifies the value of the Row Template Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Column Template Name"; Rec."Column Template Name")
                {

                    ToolTip = 'Specifies the value of the Column Template Name field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(DefaultValues)
            {
                Caption = 'Default Values';
                Image = BulletList;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip = 'Executes the Default Values action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    EventAttributeMatrix: Page "NPR Event Attribute Matrix";
                begin
                    EventAttributeMatrix.SetAttrTemplate(Rec.Name);
                    EventAttributeMatrix.Run();
                end;
            }
            action(TemplateFilters)
            {
                Caption = 'Template Filters';
                Image = "Filter";
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "NPR Event Attr. Temp. Filters";
                RunPageLink = "Template Name" = FIELD(Name);

                ToolTip = 'Executes the Template Filters action';
                ApplicationArea = NPRRetail;
            }
        }
    }
}

