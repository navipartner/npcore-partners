codeunit 6150912 "NPR HC Handle Inv. Message"
{
    var
        TooLong: Label 'Parameter %1 has value %2, which is too long. Field %3 in table %4 can be max. %5 characters. ';
        DoesntExist: Label '%1 %2 cannot be found.';
        NotSpecified: Label '%1 is not specified.';
        NoLocationsFound: Label 'No locations found to calculate inventory.';
        InventoryInLocationText: Label 'Inventory in Location %1 is %2';
        InventoryText: Label 'Inventory is %1';
        InventoryInLocationsText: Label 'Inventory in Location(s):';

    [EventSubscriber(ObjectType::Codeunit, 6150911, 'OnProcessRequest', '', true, true)]
    local procedure OnProcessRequestReturnInventoryMessage(RequestCode: Code[20]; Parameter: array[6] of Text; var Response: array[4] of Text; var IsProcessed: Boolean; var ErrorDescription: Text)
    begin
        if RequestCode <> 'INVENTORYMESSAGE' then
            exit;
        if IsProcessed then
            exit;

        IsProcessed := ProcessRequest(Parameter, Response, ErrorDescription);
    end;

    local procedure ProcessRequest(Parameter: array[6] of Text; var Response: array[4] of Text; var ErrorDescription: Text): Boolean
    var
        Inventory: Decimal;
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        Location: Record Location;
    begin
        if Parameter[1] = '' then begin
            ErrorDescription := StrSubstNo(NotSpecified, Item.TableCaption);
            exit(false);
        end;
        if StrLen(Parameter[1]) > MaxStrLen(Item."No.") then begin
            ErrorDescription := StrSubstNo(TooLong, 1, Parameter[1], Item.FieldCaption("No."), Item.TableCaption, MaxStrLen(Item."No."));
            exit(false);
        end;
        if not Item.Get(UpperCase(Parameter[1])) then begin
            ErrorDescription := StrSubstNo(DoesntExist, Item.TableCaption, Parameter[1]);
            exit(false);
        end;

        if Parameter[2] <> '' then begin
            if StrLen(Parameter[2]) > MaxStrLen(ItemVariant.Code) then begin
                ErrorDescription := StrSubstNo(TooLong, 2, Parameter[2], ItemVariant.FieldCaption(Code), ItemVariant.TableCaption, MaxStrLen(ItemVariant.Code));
                exit(false);
            end;
            if not ItemVariant.Get(Item."No.", UpperCase(Parameter[2])) then begin
                ErrorDescription := StrSubstNo(DoesntExist, ItemVariant.TableCaption, Parameter[2]);
                exit(false);
            end;
            Item.SetFilter("Variant Filter", ItemVariant.Code);
        end;

        if Parameter[3] <> '' then begin
            if UpperCase(CopyStr(Parameter[3], 1, 4)) = 'LIST' then begin
                if StrLen(Parameter[3]) > 5 then
                    Location.SetFilter(Code, UpperCase(CopyStr(Parameter[3], 6)));
                Item.CalcFields(Inventory);
                Inventory := Item.Inventory;
                if Location.FindSet then
                    repeat
                        Item.SetFilter("Location Filter", Location.Code);
                        Item.CalcFields(Inventory);
                        if Response[1] = '' then
                            Response[1] := InventoryInLocationsText;
                        Response[1] := Response[1] + '\';
                        if Location.Name <> '' then
                            Response[1] := Response[1] + Location.Name
                        else
                            Response[1] := Response[1] + Location.Code;
                        Response[1] := Response[1] + ': ' + Format(Item.Inventory);
                    until Location.Next = 0 else begin
                    ErrorDescription := NoLocationsFound;
                    exit(false);
                end;
            end else begin
                if StrLen(Parameter[3]) > MaxStrLen(Location.Code) then begin
                    ErrorDescription := StrSubstNo(TooLong, 3, Parameter[3], Location.FieldCaption(Code), Location.TableCaption, MaxStrLen(Location.Code));
                    exit(false);
                end;
                if not Location.Get(UpperCase(Parameter[3])) then begin
                    ErrorDescription := StrSubstNo(DoesntExist, Location.TableCaption, Parameter[3]);
                    exit(false);
                end;
                Item.SetFilter("Location Filter", Location.Code);
                Item.CalcFields(Inventory);
                Inventory := Item.Inventory;
                Response[1] := StrSubstNo(InventoryInLocationText, Location.Name, Format(Item.Inventory));
            end;
        end else begin
            Item.CalcFields(Inventory);
            Inventory := Item.Inventory;
            Response[1] := StrSubstNo(InventoryText, Format(Item.Inventory));
        end;

        Response[2] := Format(Inventory, 0, 9);
        exit(true);
    end;
}

