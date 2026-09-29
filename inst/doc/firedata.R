## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  eval = FALSE
)

## ----install------------------------------------------------------------------
# # Install from CRAN (when available)
# install.packages("fireData")
# # Or install development version from GitHub
# # install.packages("pak")
# pak::pak("Kohze/fireData")

## ----env-vars-----------------------------------------------------------------
# Sys.setenv(FIREBASE_PROJECT_ID = "your-project-id")
# Sys.setenv(FIREBASE_API_KEY = "your-api-key")
# Sys.setenv(FIREBASE_DATABASE_URL = "https://your-database-url")
# Sys.setenv(FIREBASE_STORAGE_BUCKET = "your-project-id.firebasestorage.app")

## ----wizard-------------------------------------------------------------------
# library(fireData)
# if (interactive()) {
#   firebase_config_wizard()
#   # Optional: save a configuration file in the temporary directory
#   config_file <- tempfile(fileext = ".yml")
#   firebase_config_wizard(save = TRUE, path = config_file)
#   unlink(config_file)
# }

## ----connection---------------------------------------------------------------
# library(fireData)
# 
# # Create connection (uses config from environment/file)
# conn <- firebase_connect()
# 
# # Or with explicit values
# conn <- firebase_connect(
#   project_id = "my-project",
#   api_key = "AIzaSy...",
#   database_url = "https://your-database-url",
#   storage_bucket = "my-project.firebasestorage.app"
# )
# 
# print(conn)

## ----store-data---------------------------------------------------------------
# # Push data with auto-generated key
# path <- rtdb_push(conn, "messages", list(
#   text = "Hello from R!",
#   author = "R User",
#   timestamp = as.character(Sys.time())
# ))
# print(path)
# # "messages/-NxYz123..."
# 
# # Set data at specific path (overwrites)
# rtdb_set(conn, "users/user123", list(
#   name = "John Doe",
#   email = "john@example.com"
# ))
# 
# # Update specific fields (merge)
# rtdb_update(conn, "users/user123", list(
#   lastLogin = as.character(Sys.time())
# ))

## ----retrieve-data------------------------------------------------------------
# # Get data from path
# user <- rtdb_get(conn, "users/user123")
# print(user$name)
# 
# # Get all messages
# messages <- rtdb_get(conn, "messages")
# 
# # Query with filtering
# results <- rtdb_query(conn, "users") |>
#   query_order_by("name") |>
#   query_limit_to_first(10) |>
#   query_execute()

## ----delete-data--------------------------------------------------------------
# rtdb_delete(conn, "messages/-NxYz123")

## ----firestore-basic----------------------------------------------------------
# # Authenticate first (Firestore requires auth)
# result <- auth_sign_in(conn, "user@example.com", "password")
# conn <- firebase_set_token(conn, result)
# 
# # Create/overwrite a document
# firestore_set(conn, "users", "user123", list(
#   name = "John Doe",
#   email = "john@example.com",
#   age = 30,
#   active = TRUE
# ))
# 
# # Add document with auto-generated ID
# result <- firestore_add(conn, "messages", list(
#   text = "Hello Firestore!",
#   timestamp = Sys.time()
# ))
# print(result$.id)  # Auto-generated document ID
# 
# # Get a document
# user <- firestore_get(conn, "users", "user123")
# print(user$name)
# 
# # Update specific fields (without overwriting entire document)
# firestore_update(conn, "users", "user123", list(
#   lastLogin = Sys.time(),
#   loginCount = 42
# ))
# 
# # Delete a document
# firestore_delete(conn, "users", "user123")

## ----firestore-list-----------------------------------------------------------
# # List all documents in a collection
# result <- firestore_list(conn, "users", page_size = 50)
# 
# for (user in result$documents) {
#   print(paste(user$name, "-", user$email))
# }
# 
# # Paginate through large collections
# result <- firestore_list(conn, "users", page_size = 10)
# while (!is.null(result$nextPageToken)) {
#   # Process result$documents
#   result <- firestore_list(conn, "users", page_size = 10,
#                            page_token = result$nextPageToken)
# }

## ----firestore-query----------------------------------------------------------
# # Query with filters
# results <- firestore_query(conn, "products") |>
#   fs_where("price", "<", 100) |>
#   fs_where("inStock", "==", TRUE) |>
#   fs_order_by("price", "asc") |>
#   fs_limit(20) |>
#   fs_execute()
# 
# for (product in results) {
#   print(paste(product$name, "- $", product$price))
# }
# 
# # Available filter operators:
# # "==" (equal), "!=" (not equal)
# # "<", "<=", ">", ">=" (comparisons)
# # "array-contains", "array-contains-any"
# # "in", "not-in"
# 
# # Select specific fields only
# results <- firestore_query(conn, "users") |>
#   fs_select("name", "email") |>
#   fs_limit(100) |>
#   fs_execute()

## ----firestore-subcollections-------------------------------------------------
# # Add a post to a user's posts subcollection
# firestore_add(conn, "users/user123/posts", list(
#   title = "My First Post",
#   content = "Hello world!",
#   created = Sys.time()
# ))
# 
# # List posts in subcollection
# posts <- firestore_list(conn, "users/user123/posts")

## ----auth-email---------------------------------------------------------------
# # Sign in
# result <- auth_sign_in(conn,
#   email = "user@example.com",
#   password = "password123"
# )
# 
# # Update connection with token
# conn <- firebase_set_token(conn, result)
# 
# # Now authenticated requests work
# rtdb_get(conn, "protected/data")
# firestore_get(conn, "private", "doc1")

## ----auth-create--------------------------------------------------------------
# result <- auth_create_user(conn,
#   email = "newuser@example.com",
#   password = "securepassword"
# )

## ----auth-anon----------------------------------------------------------------
# result <- auth_anonymous(conn)
# conn <- firebase_set_token(conn, result)

## ----storage------------------------------------------------------------------
# # Upload file
# result <- storage_upload(conn,
#   file_path = "local/image.jpg",
#   object_name = "images/photo.jpg"
# )
# print(result$url)
# 
# # Download file
# dest_file <- tempfile(fileext = ".jpg")
# storage_download(conn, "images/photo.jpg", dest_file)
# unlink(dest_file)
# 
# # List files
# files <- storage_list(conn, prefix = "images/")
# 
# # Get download URL
# url <- storage_get_url(conn, "images/photo.jpg")

## ----dataframes---------------------------------------------------------------
# # Upload mtcars dataset to Realtime Database
# rtdb_push(conn, "datasets", mtcars)
# 
# # Download as data frame
# data <- rtdb_get(conn, "datasets/-KeyHere")
# 
# # It's still a data frame!
# head(data)

## ----errors-------------------------------------------------------------------
# tryCatch({
#   auth_sign_in(conn, "wrong@email.com", "badpassword")
# }, error = function(e) {
#   message("Authentication failed: ", e$message)
# })

