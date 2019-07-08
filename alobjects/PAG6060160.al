page 6060160 "Event Attribute Templates"
{
    // NPR5.31/NPKNAV/20170502  CASE 269162 Transport NPR5.31 - 2 May 2017
    // NPR5.33/NPKNAV/20170630  CASE 277946 Transport NPR5.33 - 30 June 2017

    Caption = 'Attribute Templates';
    PageType = List;
    SourceTable = "Event Attribute Template";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Name;Name)
                {
                }
                field(Description;Description)
                {
                }
                field("Row Template Name";"Row Template Name")
                {
                }
                field("Column Template Name";"Column Template Name")
                {
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
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    EventAttributeMatrix: Page "Event Attribute Matrix";
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
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "Event Attribute Temp. Filters";
                RunPageLink = "Template Name"=FIELD(Name);
            }
        }
    }
}

