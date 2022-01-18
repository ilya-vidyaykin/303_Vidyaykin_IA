import csv
import re


def create_table(name, fields):
    if len(fields) == 0:
        return
    else:
        query = ''
        query = f'CREATE TABLE {name}(\n'
        for value in fields:
            query += f'\t{value},\n'
        query = query[0:-2] + '\n);\n'
        return query


file_name = './db_init.sql'

data_base = open(file_name, 'w+')

tables = {'movies': ['id INT PRIMARY KEY',
                     'title TEXT',
                     'year INT',
                     'genres TEXT'],
            'ratings': ['id INT PRIMARY KEY',
                     'user_id INT',
                     'movie_id INT',
                     'rating FLOAT',
                     'timestamp INT'],
            'tags': ['id INT PRIMARY KEY',
                     'user_id INT',
                     'movie_id INT',
                     'tag INT',
                     'timestamp INT',
                     ],
            'users': ['id INT PRIMARY KEY',
                      'name TEXT',
                      'email TEXT',
                      'gender TEXT',
                      'register_date TEXT',
                      'occupation TEXT',
                      ]
          }

for table_key in tables:
    data_base.write(f'drop table if exists {table_key};\n')
    data_base.write(create_table(f'{table_key}', tables[table_key]))

data_base.write('insert into movies(id, title, year, genres) values\n')

movies_file = open('movies.csv', 'r')
all_movies = ""
reader = csv.DictReader(movies_file)
for film in reader:
    title = film['title'].replace('"', '""').replace("'", "''")
    year = (lambda res: res.group(0) if res is not None else 'null')(re.search(r'\d{4}', film['title']))
    all_movies += f"({film['movieId']}, '{title}', {year}, '{film['genres']}'),\n"
data_base.write(f'\n{all_movies[:-2]};\n\n')
movies_file.close()


data_base.write('insert into ratings(id, user_id, movie_id, rating, timestamp) values\n')

ratings_file = open('ratings.csv')
all_ratings = ""
reader = csv.DictReader(ratings_file)
id = 1
for rating_row in reader:
    timestamp = rating_row['timestamp']
    all_ratings += f"({id}, {rating_row['userId']}, {rating_row['movieId']}, {rating_row['rating']}, {rating_row['timestamp']}),\n"
    id += 1
data_base.write(f'\n{all_ratings[:-2]};\n\n')
ratings_file.close()


data_base.write('insert into tags(id, user_id, movie_id, tag, timestamp) values\n')
tags_file = open('tags.csv')
all_tags = ""
reader = csv.DictReader(tags_file)
id = 1
for tag_row in reader:
    tag = tag_row['tag'].replace('"', '""').replace("'", "''")
    all_tags += f"({id}, {tag_row['userId']}, {tag_row['movieId']}, '{tag}', {tag_row['timestamp']}),\n"
    id += 1
data_base.write(f'\n{all_tags[:-2]};\n\n')
tags_file.close()


data_base.write('insert into users(id, name, email, gender, register_date, occupation) values\n')
user_file = open('users.txt')
all_users = ""
for user in user_file.readlines():
    user = user.rstrip().replace('"', '""').replace("'", "''").split('|')
    all_users += f"({user[0]}, '{user[1]}', '{user[2]}', '{user[3]}', '{user[4]}', '{user[5]}'),\n"
data_base.write(f'\n{all_users[:-2]};')
user_file.close()

data_base.close()
