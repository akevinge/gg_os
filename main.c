#include <uefi.h>

#include "utils.h"

efi_status_t open_gop(efi_gop_t **gop)
{
    efi_guid_t gop_guid = EFI_GRAPHICS_OUTPUT_PROTOCOL_GUID;
    return BS->LocateProtocol(&gop_guid, NULL, (void **)gop);
}

efi_status_t clear_screen()
{
    // Reset the STDOUT and STDERR without extensive error checking.
    // Resetting with bit 0 in the second argument clears the screen without
    // performing device checks.
    RETURN_IF_ERROR(ST->ConOut->Reset(ST->ConOut, 0));
    return ST->StdErr->Reset(ST->StdErr, 0);
}

efi_status_t query_screen_info(efi_gop_t *gop, efi_gop_mode_info_t **info)
{
    uintn_t size_of_info = sizeof(**info);
    return gop->QueryMode(gop, gop->Mode->Mode, &size_of_info, info);
}

efi_status_t draw_box(efi_gop_t *gop, efi_gop_mode_info_t *info)
{
    uint32_t *data = malloc(info->HorizontalResolution * info->VerticalResolution * sizeof(uint32_t));
    for (size_t i = 0; i < info->HorizontalResolution * info->VerticalResolution; i++)
    {
        data[i] = 0xFFFF0000; // Red
    }
    RETURN_IF_NULL(data, EFI_OUT_OF_RESOURCES);
    RETURN_AND_LOG_IF_ERROR(gop->Blt(gop, data, EfiBltBufferToVideo, 0, 0, 0, 0, info->HorizontalResolution, info->VerticalResolution, 0), "Failed to draw to screen.\n");
}

int main(int argc, char **argv)
{
    // Locate the Graphics Output Protocol.
    efi_gop_t *gop = NULL;
    RETURN_AND_LOG_IF_ERROR(open_gop(&gop), "Failed to locate Graphics Output Protocol.\n");
    RETURN_AND_LOG_IF_NULL(gop, EFI_UNSUPPORTED, "Failed to locate Graphics Output Protocol.\n");

    // Query the screen information.
    efi_gop_mode_info_t *info = NULL;
    RETURN_AND_LOG_IF_ERROR(query_screen_info(gop, &info), "Failed to query screen information.\n");

    // Clear the screen.
    RETURN_AND_LOG_IF_ERROR(clear_screen(), "Failed to clear the screen.\n");

    draw_box(gop, info);
    sleep(10);
    return 0;
}
