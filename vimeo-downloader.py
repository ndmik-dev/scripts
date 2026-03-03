#!/usr/bin/env python3
import argparse
import os
import sys

def download_vimeo_video(embed_url: str, referer: str, output_dir: str, cookies: str | None,
                         verbose: bool, info_only: bool) -> int:
    try:
        import yt_dlp
    except ImportError:
        print("Error: yt-dlp is not installed. Install it with: python3 -m pip install yt-dlp")
        return 1

    os.makedirs(output_dir, exist_ok=True)

    ydl_opts = {
        'format': 'bv*+ba/best',
        'outtmpl': os.path.join(output_dir, '%(title)s.%(ext)s'),
        'merge_output_format': 'mp4',
        'http_headers': {
            'Referer': referer
        },
        'quiet': not verbose,
        'no_warnings': not verbose,
    }

    if cookies:
        ydl_opts['cookiefile'] = cookies

    with yt_dlp.YoutubeDL(ydl_opts) as ydl:
        try:
            print(f"URL: {embed_url}")
            print(f"Referer: {referer}")
            print(f"Output: {output_dir}")
            if cookies:
                print(f"Cookies: {cookies}")
            print()

            if info_only:
                info = ydl.extract_info(embed_url, download=False)
                title = info.get("title")
                duration = info.get("duration")
                print("Info fetched")
                print(f"Title: {title}")
                if duration:
                    print(f"Duration: {duration} sec")
                return 0

            ydl.download([embed_url])
            print("\nDownload complete")
            return 0

        except Exception as exc:
            print(f"\nError: {exc}")
            return 2

def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="Download a Vimeo video with a required Referer header."
    )
    parser.add_argument(
        "url",
        nargs="?",
        help="Vimeo URL, for example https://player.vimeo.com/video/123456789"
    )
    parser.add_argument(
        "--referer",
        help="The page where the Vimeo player is embedded."
    )
    parser.add_argument(
        "-o", "--output-dir",
        default="downloads",
        help="Directory to save files (default: ./downloads)."
    )
    parser.add_argument(
        "--cookies",
        help="Path to cookies.txt in Netscape format if login is required."
    )
    parser.add_argument(
        "-v", "--verbose",
        action="store_true",
        help="Verbose output."
    )
    parser.add_argument(
        "--info",
        action="store_true",
        help="Only fetch metadata without downloading the video."
    )
    return parser

def main() -> int:
    parser = build_parser()
    args = parser.parse_args()

    url = args.url or input("Enter Vimeo URL (player.vimeo.com preferred): ").strip()
    referer = args.referer or input("Enter Referer (page where video is embedded): ").strip()

    if not url or not referer:
        parser.error("URL and Referer are required.")

    if args.cookies and not os.path.isfile(args.cookies):
        parser.error(f"Cookies file not found: {args.cookies}")

    return download_vimeo_video(
        embed_url=url,
        referer=referer,
        output_dir=args.output_dir,
        cookies=args.cookies,
        verbose=args.verbose,
        info_only=args.info
    )

if __name__ == "__main__":
    sys.exit(main())
