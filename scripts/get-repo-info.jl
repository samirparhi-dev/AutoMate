import Pkg
Pkg.add(["HTTP", "JSON","Dates"])
using HTTP, JSON, Dates

function get_repo_info(owner::String, repo::String)
    # GitHub API URL for repository
    url = "https://api.github.com/repos/$owner/$repo"

    # Sending GET request to GitHub API
    response = HTTP.get(url)

    # Parsing the JSON response
    repo_data = JSON.parse(String(response.body))

    # Extract the necessary fields from the response
    repo_info = Dict(
        "id" => repo_data["id"],
        "bes_tracking_id" => repo_data["id"],
        "issue_url" => "",
        "name" => repo_data["name"],
        "full_name" => repo_data["full_name"],
        "description" => repo_data["description"],
        "bes_technology_stack" => "A",  # Manually set, modify as needed
        "watchers_count" => repo_data["watchers_count"],
        "forks_count" => repo_data["forks_count"],
        "stargazers_count" => repo_data["stargazers_count"],
        "size" => repo_data["size"],
        "open_issues" => repo_data["open_issues_count"],
        "created_at" => repo_data["created_at"],
        "updated_at" => repo_data["updated_at"],
        "pushed_at" => repo_data["pushed_at"],
        "git_url" => repo_data["git_url"],
        "clone_url" => repo_data["clone_url"],
        "html_url" => repo_data["html_url"],
        "homepage" => repo_data["homepage"],
        "owner" => Dict(
            "login" => repo_data["owner"]["login"],
            "type" => repo_data["owner"]["type"],
            "site_admin" => repo_data["owner"]["site_admin"]
        ),
        "project_repos" => Dict(
            "main_github_url" => repo_data["html_url"],
            "main_bes_url" => repo_data["html_url"],
            "all_projects" => [
                Dict("id" => repo_data["id"], "name" => repo_data["full_name"], "url" => repo_data["html_url"])
            ],
            "all_bes_repos" => [
                Dict("id" => repo_data["id"], "name" => repo_data["full_name"], "url" => repo_data["html_url"])
            ]
        ),
        "license" => Dict(
            "key" => repo_data["license"]["key"],
            "name" => repo_data["license"]["name"],
            "spdx_id" => repo_data["license"]["spdx_id"],
            "url" => repo_data["license"]["url"],
            "node_id" => repo_data["license"]["node_id"]
        ),
        "language" => JSON.parse(String(HTTP.get(repo_data["languages_url"]).body)),
        "tags" => ["A", "SD-AS", "SD-DS", "TD-U-ApD", "ALL", "TD-C-S", "TD-C-WA", "TD-C-A", "COM-C"]
    )

    return repo_info
end

function save_json_to_file(data::Dict, filename::String)
    # Get current working directory and construct the full file path
    workspace_dir = ENV["GITHUB_WORKSPACE"]
    # workspace_dir = pwd()
    file_path = joinpath(workspace_dir, filename)
    
    # Open the file and save JSON data
    open(file_path, "w") do file
        write(file, JSON.json(data, 4))  # Writing JSON data with indentation
    end
    
    println("Data saved to $file_path")
end


# Example usage:
owner = ARGS[1]
repo = ARGS[2]
repo_info = get_repo_info(owner, repo)
current_datetime = now()
file_name = string(repo, "_", current_datetime, ".json")

# Save the JSON data to a file
save_json_to_file(repo_info, file_name)
