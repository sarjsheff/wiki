## apache maven

### Help для pluginа

```
mvn help:describe -DgroupId=org.somewhere -DartifactId=some-plugin -Dversion=0.0.0
```

Краткая форма по названию плугина:

```
mvn help:describe -Dplugin=some-plugin
```

Примеры:

```
mvn help:describe -Ddetail=true -DgroupId=org.apache.maven.plugins -DartifactId=maven-help-plugin -Dversion=LATEST -Dgoal=describe

mvn help:describe -Dplugin=help
```

### Зависимости

```
mvn help:describe -DgroupId=org.apache.maven.plugins -DartifactId=maven-dependency-plugin -Dversion=LATEST
```

| cmd                                                          | Описание                                     |
| ------------------------------------------------------------ | -------------------------------------------- |
| `mvn dependency:list`                                        | Список зависимостей                          |
| `mvn dependency:tree`                                        | Дерево зависимостей                          |
| `mvn dependency:tree -DoutputType=dot -DoutputFile=test.dot` | Дерево зависимостей в DOT (graphviz) формате |
