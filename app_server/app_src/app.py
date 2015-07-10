import argparse
import cherrypy
import os
import pymongo
from redis import Redis


root_path = os.path.abspath(os.path.dirname(__file__))
servers={
    'mongo':'mongodb',
    'redis':'redis'
}


class Root(object):

    @cherrypy.expose
    def index(self):
        return open(root_path + "/index.html").read()


    @cherrypy.expose()
    @cherrypy.tools.json_out(on=True)
    def connect_to_mongodb(self):
        try:
            self.conn=pymongo.MongoClient(servers['mongo'])
            self.conn.mydb.mycollection.insert({'x':0})
            return True
        except Exception as e:
            return False

    @cherrypy.expose()
    @cherrypy.tools.json_out(on=True)
    def insert_into_mongo(self):
        try:
            self.conn.mydb.mycollection.update({},{'$inc': {'x': 1}}, upsert=True)
            return True
        except Exception as e:
            return False

    @cherrypy.expose()
    @cherrypy.tools.json_out(on=True)
    def read_mongo(self):
        try:
            cursor = self.conn.mydb.mycollection.find()
            if cursor.count():
                doc= cursor.next()
                return doc['x']
            return 0
        except Exception as e:
            return False


    @cherrypy.expose()
    @cherrypy.tools.json_out(on=True)
    def connect_to_redis(self):
        try:
            self.redis = Redis(servers['redis'], port=6379)
            self.redis.incr('hits')
            return True
        except Exception as e:
            return False

    @cherrypy.expose()
    @cherrypy.tools.json_out(on=True)
    def insert_into_redis(self):
        try:
            self.redis.incr('hits')
            return True
        except Exception as e:
            return False

    @cherrypy.expose()
    @cherrypy.tools.json_out(on=True)
    def read_redis(self):
        try:
            return self.redis.get('hits')
        except Exception as e:
            return False




def main(port):
    root = Root()
    cherrypy.config.update({
        'server.socket_host': '0.0.0.0',
        'server.socket_port': port,

    })

    cherrypy_conf = {
        '/assets': {
            'tools.gzip.on': True,
            'tools.gzip.mime_types': ['text/css', 'text/javascript', 'image/png'],
            'tools.staticdir.on': True,
            'tools.staticdir.dir': os.path.join(root_path, 'assets'),
            'tools.expires.on': True,
            'tools.expires.secs': 1000

        }
    }

    cherrypy.quickstart(root, "/", cherrypy_conf)


if __name__ == '__main__':
    main(5000)
