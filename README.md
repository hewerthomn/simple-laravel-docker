# Simple Laravel Docker

A simple *yet* Laravel Docker running on **Ubuntu 20.04 LTS** and serving **PHP 7.4** with **nginx**, with **Node. js v12** and **Composer 2** .


## Clone and build

```bash
git clone https://github.com/hewerthomn/simple-laravel-docker.git simple-laravel-docker
cd simple-laravel-docker
docker build -t simple-laravel-docker:7.4 .
```

## Running docker

Now copy `docker-compose.yml` file to your laravel project folder
and make necessary changes in environment variables if needed.

```bash
cd /path/to/laravel-project/
docker-compose up
```

## Show!

If your docker is running you can access it in:

[http://localhost:3000](http://localhost:3000)


## License

This project is licensed under the [MIT License](LICENSE)
