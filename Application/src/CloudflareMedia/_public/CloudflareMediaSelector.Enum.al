enum 6059923 "NPR CloudflareMediaSelector" implements "NPR CloudflareMigrationInterface"
{
    Extensible = true;

    value(0; NOOP)
    {
        Caption = '';
        Implementation = "NPR CloudflareMigrationInterface" = "NPR CloudflareMediaImpl";
    }

    value(100; MEMBER_PHOTO)
    {
        Caption = 'Member Photo';
        Implementation = "NPR CloudflareMigrationInterface" = "NPR MMMemberImageMediaHandler";
    }
#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
    value(200; RESTAURANT_LOGO)
    {
        Caption = 'Restaurant Logo';
        Implementation = "NPR CloudflareMigrationInterface" = "NPR NPRERestaurantLogoHandler";
    }

    value(201; MENU_ITEM_PICTURE)
    {
        Caption = 'Menu Item Picture';
        Implementation = "NPR CloudflareMigrationInterface" = "NPR NPREMenuItemPictureHandler";
    }
#endif
}