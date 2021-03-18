page 6060160 "NPR Event Attribute Templ."
{
    Caption = 'Attribute Templates';
    PageType = List;
    SourceTable = "NPR Event Attribute Template";
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Name; Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Row Template Name"; "Row Template Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Row Template Name field';
                }
                field("Column Template Name"; "Column Template Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Column Template Name field';
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
                ApplicationArea = All;
                ToolTip = 'Executes the Default Values action';

                trigger OnAction()
                var
                    EventAttributeMatrix: Page "NPR Event Attribute Matrix";
                begin
                    EventAttributeMatrix.SetAttrTemplate(Rec.Name);
                    EventAttributeMatrix.Run;
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
                ApplicationArea = All;
                ToolTip = 'Executes the Template Filters action';
            }
        }
    }
}

