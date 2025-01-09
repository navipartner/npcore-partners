page 6184904 "NPR NPDesignerTemplateList"
{
    Extensible = false;
    Caption = 'NPDesigner Templates';
    DataCaptionFields = Description;
    Editable = false;
    PageType = List;
    UsageCategory = None;

    SourceTable = "NPR NPDesignerTemplates";
    SourceTableView = Sorting(Description);
    SourceTableTemporary = true;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {

                field(ExternalId; Rec.ExternalId)
                {
                    ToolTip = 'Specifies the value of the ExternalId field.', Comment = '%';
                    ApplicationArea = NPRRetail;
                    Visible = false;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field.', Comment = '%';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    internal procedure SetCaption(NewCaption: Text)
    begin
        CurrPage.Caption(NewCaption);
    end;

    internal procedure SetData(var AvailableTemplates: Record "NPR NPDesignerTemplates" temporary)
    begin
        Rec.Copy(AvailableTemplates, true);
    end;
}