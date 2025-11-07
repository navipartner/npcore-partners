codeunit 6248654 "NPR NPDesignerFacade"
{
    Access = Public;

    /// <summary>
    /// Queries the designer repository for saved designs that match the specified design type, presents the matching results in a modal selection dialog, and returns the user's selection(s).
    /// </summary>
    /// <param name="Type"></param>
    /// <param name="LookupCaption"></param>
    /// <param name="NPDesignerTemplateId"></param>
    /// <param name="NPDesignerTemplateLabel"></param>

    procedure LookupDesignLayouts(Type: Text; LookupCaption: Text; var NPDesignerTemplateId: Text[40]; var NPDesignerTemplateLabel: Text[80])
    var
        Designer: Codeunit "NPR NPDesigner";
    begin
        Designer.LookupDesignLayouts(Type, LookupCaption, NPDesignerTemplateId, NPDesignerTemplateLabel);
    end;

    /// <summary>
    /// Validates that the specified design template label exists (case insensitive) in the designer repository for the specified design type. If it exists, the corresponding label and ID is returned.
    /// </summary>
    /// <param name="Type"></param>
    /// <param name="NPDesignerTemplateId"></param>
    /// <param name="NPDesignerTemplateLabel"></param>

    procedure ValidateDesignLayouts(Type: Text; var NPDesignerTemplateId: Text[40]; var NPDesignerTemplateLabel: Text[80])
    var
        Designer: Codeunit "NPR NPDesigner";
    begin
        Designer.ValidateDesignLayouts(Type, NPDesignerTemplateId, NPDesignerTemplateLabel);
    end;

#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
    /// <summary>
    /// Retrieves design templates from the designer repository for the specified design type.
    /// </summary>
    /// <param name="Type"></param>
    procedure GetDesignsTemplates(Type: Text) DesignerTemplates: Record "NPR NPDesignerTemplates" temporary
    var
        Designer: Codeunit "NPR NPDesigner";
    begin
        Designer.GetDesignerTemplates(Type, DesignerTemplates);
    end;
#endif
}
