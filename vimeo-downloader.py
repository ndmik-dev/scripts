#!/usr/bin/env python3
import argparse
import os
import sys
import yt_dlp

def download_vimeo_video(embed_url: str, referer: str, output_dir: str, cookies: str | None,
                         verbose: bool, info_only: bool):
    os.makedirs(output_dir, exist_ok=True)

    ydl_opts = {
        # Best video+audio, fallback to best single file
        'format': 'bv*+ba/best',
        # Save into output_dir with title
        'outtmpl': os.path.join(output_dir, '%(title)s.%(ext)s'),
        # Vimeo often splits audio/video; merge to mp4 (requires ffmpeg)
        'merge_output_format': 'mp4',
        # Helpful for embedded/private-ish pages
        'http_headers': {
            'Referer': referer
        },
        # Less noisy by default
        'quiet': not verbose,
        'no_warnings': not verbose,
    }

    # Optional cookies file (exported from your browser)
    # Format: Netscape cookies.txt (common for yt-dlp)
    if cookies:
        ydl_opts['cookiefile'] = cookies

    with yt_dlp.YoutubeDL(ydl_opts) as ydl:
        try:
            print(f"\n➡️  URL: {embed_url}")
            print(f"➡️  Referer: {referer}")
            print(f"➡️  Output: {output_dir}")
            if cookies:
                print(f"➡️  Cookies: {cookies}")
            print()

            if info_only:
                info = ydl.extract_info(embed_url, download=False)
                title = info.get("title")
                duration = info.get("duration")
                print("✅ Info fetched")
                print(f"Title: {title}")
                if duration:
                    print(f"Duration: {duration} sec")
                return

            ydl.download([embed_url])
            print("\n✅ Download complete")

        except Exception as e:
            print(f"\n❌ Error: {e}")
            sys.exit(2)

def main():
    parser = argparse.ArgumentParser(
        description="Download Vimeo video (embed URL) with a required Referer header."
    )
    parser.add_argument(
        "url",
        nargs="?",
        help="Vimeo URL (embed/player preferred), e.g. https://player.vimeo.com/video/123456789"
    )
    parser.add_argument(
        "--referer",
        help="The page where the Vimeo player is embedded (required for many sites)."
    )
    parser.add_argument(
        "-o", "--output-dir",
        default="downloads",
        help="Directory to save files (default: ./downloads)."
    )
    parser.add_argument(
        "--cookies",
        help="Path to cookies.txt (Netscape format) if login is required."
    )
    parser.add_argument(
        "-v", "--verbose",
        action="store_true",
        help="Verbose output."
    )
    parser.add_argument(
        "--info",
        action="store_true",
        help="Only fetch metadata (no download)."
    )

    args = parser.parse_args()

    # Interactive fallback if URL/referer not provided
    url = args.url or input("Enter Vimeo URL (player.vimeo.com preferred): ").strip()
    referer = args.referer or input("Enter Referer (page where video is embedded): ").strip()

    if not url or not referer:
        print("❌ URL and Referer are required.")
        print("Example:")
        print("  python3 vimeo_downloader.py https://player.vimeo.com/video/123 --referer https://example.com/page")
        sys.exit(1)

    download_vimeo_video(
        embed_url=url,
        referer=referer,
        output_dir=args.output_dir,
        cookies=args.cookies,
        verbose=args.verbose,
        info_only=args.info
    )

if __name__ == "__main__":
    main()
