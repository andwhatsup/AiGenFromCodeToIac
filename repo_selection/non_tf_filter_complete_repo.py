import re
import sys

def filter_repos(input_filename="complete_repo_urls.log", output_filename="non_terraform_repos.log"):
    """
    Reads a log file, extracts 'rid' and 'url' fields, and filters out lines
    where the URL contains common Terraform-related repository naming patterns.
    """

    # 1. Define the exclusion patterns (case-insensitive)
    EXCLUSION_PATTERNS = [
        r'terraform-aws-',
        r'terraform-azurerm-',
        r'terraform-google-',
        r'-terraform-',
        r'-tf-',
        r'/terraform-?modules?/',
        r'terraform' # The new, general 'terraform' exclusion
    ]

    # 2. Regex to reliably extract rid and url from the line
    # It looks for 'rid=' followed by digits, and 'url=' followed by the URL
    # We use a non-greedy match (.*?) to capture the data between the fields.
    LINE_PATTERN = re.compile(r'rid=([^ ]+).*?url=([^ ]+)')

    # 3. Compile the exclusion patterns into a single, case-insensitive regex
    # The 're.IGNORECASE' flag handles the '-i' (ignore case) from your grep command.
    exclusion_regex = re.compile('|'.join(EXCLUSION_PATTERNS), re.IGNORECASE)

    filtered_count = 0
    total_count = 0

    try:
        with open(input_filename, 'r') as infile, open(output_filename, 'w') as outfile:
            print(f"Reading from: {input_filename}")
            print(f"Writing filtered results to: {output_filename}")

            for line in infile:
                total_count += 1
                
                # Check if the line has the basic structure (rid= and url=)
                match = LINE_PATTERN.search(line)
                
                if match:
                    rid = match.group(1).strip()
                    url = match.group(2).strip()

                    # 4. Check for exclusion patterns in the URL
                    if exclusion_regex.search(url):
                        # Line matches an exclusion pattern, so we skip it
                        continue
                    
                    # 5. Output the result in the desired format
                    output_line = f"rid={rid} url={url}\n"
                    outfile.write(output_line)
                    filtered_count += 1
                
                # Optional: Handle lines that exist but don't match the format
                # else:
                #     print(f"Skipped unformatted line: {line.strip()}", file=sys.stderr)

            print(f"\nProcessing complete.")
            print(f"Total lines processed: {total_count}")
            print(f"Lines saved: {filtered_count}")

    except FileNotFoundError:
        print(f"Error: Input file '{input_filename}' not found.", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    # Use the default filename or pass it as an argument
    filter_repos()
    
# To run this script, save it as filter_repos.py and execute:
# python filter_repos.py
# (It assumes your log file is named complete_repo_urls.log)